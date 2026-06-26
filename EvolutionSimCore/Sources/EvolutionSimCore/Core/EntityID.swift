import Foundation

public struct EntityID: Codable, Equatable, Hashable, Sendable {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}

public struct EntityIDGenerator: Codable, Equatable, Sendable {
    private var nextID: UInt64

    public init(startingAt: UInt64 = 1) {
        self.nextID = startingAt
    }

    public mutating func next() -> EntityID {
        let id = EntityID(rawValue: nextID)
        nextID &+= 1
        return id
    }
}
