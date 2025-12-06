// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Entity
import Foundation
import Networking
import Storage

public final class SelectedUnitsStorageProtocolMock: SelectedUnitsStorageProtocol {

    public init() {}

    // MARK: - save

    public var saveUnitsCallsCount = 0
    public var saveUnitsReceivedUnits: [SelectedUnit]?

    public func save(units: [SelectedUnit]) {
        saveUnitsCallsCount += 1
        saveUnitsReceivedUnits = units
    }

    // MARK: - loadSortedNames

    public var loadSortedNamesCallsCount = 0
    public var loadSortedNamesReturnValue: [String]!

    public func loadSortedNames() -> [String] {
        loadSortedNamesCallsCount += 1
        return loadSortedNamesReturnValue
    }

    // MARK: - load

    public var loadCallsCount = 0
    public var loadReturnValue: [SelectedUnit]!

    public func load() -> [SelectedUnit] {
        loadCallsCount += 1
        return loadReturnValue
    }
}
