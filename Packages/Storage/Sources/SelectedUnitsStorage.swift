//
//  SelectedUnitsStorage.swift
//  Storage
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import Foundation
import MockSupport

public protocol SelectedUnitsStorageProtocol: AutoMockable {
    func save(units: [SelectedUnit])
    func loadSortedNames() -> [String]
    func load() -> [SelectedUnit]
}

public struct SelectedUnitsStorage: SelectedUnitsStorageProtocol, Sendable {
    private let key = "selectedUnits"

    public init() {}

    public func save(units: [SelectedUnit]) {
        guard let data = try? JSONEncoder().encode(units) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// position順でソート済みのユニット名を返す
    public func loadSortedNames() -> [String] {
        load()
            .sorted { $0.position < $1.position }
            .map(\.name)
    }

    public func load() -> [SelectedUnit] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let units = try? JSONDecoder().decode([SelectedUnit].self, from: data)
        else {
            return []
        }
        return units
    }
}

public protocol FilteredUnitsStorageProtocol: AutoMockable {
    func save(names: [String])
    func load() -> [String]
}

public struct FilteredUnitsStorage: FilteredUnitsStorageProtocol, Sendable {
    private let key = "filteredUnitNames"

    public init() {}

    public func save(names: [String]) {
        UserDefaults.standard.set(names, forKey: key)
    }

    public func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
