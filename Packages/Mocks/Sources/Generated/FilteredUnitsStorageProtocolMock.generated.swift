// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Entity
import Foundation
import Networking
import Storage

public final class FilteredUnitsStorageProtocolMock: FilteredUnitsStorageProtocol {

    public init() {}

    // MARK: - save

    public var saveNamesCallsCount = 0
    public var saveNamesReceivedNames: [String]?

    public func save(names: [String]) {
        saveNamesCallsCount += 1
        saveNamesReceivedNames = names
    }

    // MARK: - load

    public var loadCallsCount = 0
    public var loadReturnValue: [String]!

    public func load() -> [String] {
        loadCallsCount += 1
        return loadReturnValue
    }

    // MARK: - clear

    public var clearCallsCount = 0

    public func clear() {
        clearCallsCount += 1
    }
}
