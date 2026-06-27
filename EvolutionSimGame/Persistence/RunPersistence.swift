import Foundation
import EvolutionSimCore

let RunSaveSchemaVersion = 1

enum PersistedRunAppPhase: String, Codable, Equatable, Sendable {
    case playing
}

struct RunSessionState: Codable, Equatable, Sendable {
    var appPhase: PersistedRunAppPhase
    var hasPresentedMutationChoiceThisRun: Bool
    var deferredMutationPresentationTicks: Int

    init(
        appPhase: PersistedRunAppPhase = .playing,
        hasPresentedMutationChoiceThisRun: Bool,
        deferredMutationPresentationTicks: Int
    ) {
        self.appPhase = appPhase
        self.hasPresentedMutationChoiceThisRun = hasPresentedMutationChoiceThisRun
        self.deferredMutationPresentationTicks = deferredMutationPresentationTicks
    }
}

struct PersistedRun: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var savedAt: Date
    var simulation: SavedSimulation
    var session: RunSessionState

    init(
        schemaVersion: Int = RunSaveSchemaVersion,
        savedAt: Date = Date(),
        simulation: SavedSimulation,
        session: RunSessionState
    ) {
        self.schemaVersion = schemaVersion
        self.savedAt = savedAt
        self.simulation = simulation
        self.session = session
    }
}

struct SavedRunSummary: Equatable, Sendable {
    var seed: UInt64
    var tick: Int
    var phase: SimulationPhase
    var victoryGoal: VictoryGoal
    var savedAt: Date

    init(run: PersistedRun) {
        seed = run.simulation.state.config.seed
        tick = run.simulation.state.tick
        phase = run.simulation.state.phase
        victoryGoal = run.simulation.state.config.victoryGoal
        savedAt = run.savedAt
    }
}

enum RunPersistenceError: LocalizedError {
    case saveNotFound
    case incompatibleNewerSchema(found: Int, supported: Int)
    case unsupportedOlderSchema(found: Int, supported: Int)
    case corruptSave(underlying: Error)
    case filesystem(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .saveNotFound:
            return "No saved run was found."
        case let .incompatibleNewerSchema(found, supported):
            return "This save was created by a newer build (schema \(found)). This build supports schema \(supported)."
        case let .unsupportedOlderSchema(found, supported):
            return "This save uses older schema \(found). Migration is not implemented yet for schema \(supported)."
        case .corruptSave:
            return "The saved run could not be read."
        case .filesystem:
            return "The saved run could not be accessed on disk."
        }
    }
}

/// Phase 9 beta policy:
/// - schemaVersion `1` is the only supported envelope version.
/// - newer versions are rejected gracefully so the app never crashes on launch/continue.
/// - older versions are also rejected for now; future migrations should be centralized here.
final class RunPersistenceService {
    private struct EnvelopeHeader: Decodable {
        let schemaVersion: Int
    }

    private let fileManager: FileManager
    private let baseDirectory: URL?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileManager = fileManager
        self.baseDirectory = baseDirectory
        self.encoder = encoder
        self.decoder = decoder
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func hasSavedRun() -> Bool {
        guard let url = try? activeRunURL() else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    func save(_ persistedRun: PersistedRun) throws {
        do {
            let directory = try runsDirectoryURL()
            let destination = try activeRunURL()
            let tempURL = directory.appendingPathComponent("active-run-\(UUID().uuidString).json.tmp")
            let data = try encoder.encode(persistedRun)

            if fileManager.fileExists(atPath: tempURL.path) {
                try? fileManager.removeItem(at: tempURL)
            }

            try data.write(to: tempURL, options: [.atomic])

            if fileManager.fileExists(atPath: destination.path) {
                _ = try fileManager.replaceItemAt(destination, withItemAt: tempURL)
            } else {
                try fileManager.moveItem(at: tempURL, to: destination)
            }
        } catch let error as RunPersistenceError {
            throw error
        } catch {
            throw RunPersistenceError.filesystem(underlying: error)
        }
    }

    func load() throws -> PersistedRun {
        let url = try activeRunURL()
        guard fileManager.fileExists(atPath: url.path) else {
            throw RunPersistenceError.saveNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw RunPersistenceError.filesystem(underlying: error)
        }

        do {
            let header = try decoder.decode(EnvelopeHeader.self, from: data)
            if header.schemaVersion > RunSaveSchemaVersion {
                throw RunPersistenceError.incompatibleNewerSchema(
                    found: header.schemaVersion,
                    supported: RunSaveSchemaVersion
                )
            }
            if header.schemaVersion < RunSaveSchemaVersion {
                throw RunPersistenceError.unsupportedOlderSchema(
                    found: header.schemaVersion,
                    supported: RunSaveSchemaVersion
                )
            }
            return try decoder.decode(PersistedRun.self, from: data)
        } catch let error as RunPersistenceError {
            throw error
        } catch {
            throw RunPersistenceError.corruptSave(underlying: error)
        }
    }

    func loadSummary() throws -> SavedRunSummary {
        SavedRunSummary(run: try load())
    }

    func delete() throws {
        let url = try activeRunURL()
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw RunPersistenceError.filesystem(underlying: error)
        }
    }

    @discardableResult
    func quarantineActiveRun() throws -> URL {
        let source = try activeRunURL()
        guard fileManager.fileExists(atPath: source.path) else {
            throw RunPersistenceError.saveNotFound
        }

        do {
            let directory = try runsDirectoryURL()
            let quarantineDirectory = directory.appendingPathComponent("Corrupt Saves", isDirectory: true)
            try fileManager.createDirectory(at: quarantineDirectory, withIntermediateDirectories: true)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let destination = quarantineDirectory
                .appendingPathComponent("active-run-\(formatter.string(from: Date()))")
                .appendingPathExtension("json")
            try fileManager.moveItem(at: source, to: destination)
            return destination
        } catch {
            throw RunPersistenceError.filesystem(underlying: error)
        }
    }

    private func runsDirectoryURL() throws -> URL {
        let rootDirectory: URL
        if let baseDirectory {
            rootDirectory = baseDirectory
        } else {
            guard let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw RunPersistenceError.filesystem(
                    underlying: CocoaError(.fileNoSuchFile)
                )
            }
            rootDirectory = applicationSupport.appendingPathComponent("EvolutionSimGame", isDirectory: true)
        }

        do {
            try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
            return rootDirectory
        } catch {
            throw RunPersistenceError.filesystem(underlying: error)
        }
    }

    private func activeRunURL() throws -> URL {
        try runsDirectoryURL().appendingPathComponent("active-run").appendingPathExtension("json")
    }
}

extension SimulationPhase {
    var displayName: String {
        switch self {
        case .playing:
            return "Playing"
        case .awaitingMutationChoice:
            return "Awaiting Mutation"
        case .extinct:
            return "Extinct"
        case .victory:
            return "Victory"
        }
    }
}
