//
//  FilterUnitsViewModel.swift
//  FilterUnitsFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Networking
import Observation
import SharedViews
import Storage
import SwiftUI

@MainActor
protocol FilterUnitsViewModelInputs {
    func fetchUnits() async
    func toggleSelection(_ unit: GameUnit)
    func clearAll()
    func save()
}

@MainActor
protocol FilterUnitsViewModelOutputs {
    var allUnits: [GameUnit] { get }
    var selectedUnitNames: Set<String> { get }
    var isLoading: Bool { get }
    var toastMessage: Binding<ToastMessage?> { get }
}

@MainActor
protocol FilterUnitsViewModelType: FilterUnitsViewModelInputs, FilterUnitsViewModelOutputs {
    var inputs: FilterUnitsViewModelInputs { get }
    var outputs: FilterUnitsViewModelOutputs { get }
}

@MainActor
@Observable
final class FilterUnitsViewModel: FilterUnitsViewModelType {
    private let client: FireStoreClientProtocol
    private let filteredUnitsStorage: FilteredUnitsStorageProtocol

    private var _allUnits: [GameUnit] = []
    private var _selectedUnitNames: Set<String> = []
    private var _isLoading = false
    private var _toastMessage: ToastMessage?

    var inputs: FilterUnitsViewModelInputs { self }
    var outputs: FilterUnitsViewModelOutputs { self }

    init(
        client: FireStoreClientProtocol = FireStoreClient(),
        filteredUnitsStorage: FilteredUnitsStorageProtocol = FilteredUnitsStorage()
    ) {
        self.client = client
        self.filteredUnitsStorage = filteredUnitsStorage
    }
}

// MARK: - FilterUnitsViewModelInputs
extension FilterUnitsViewModel: FilterUnitsViewModelInputs {
    func fetchUnits() async {
        guard !_isLoading else { return }

        _isLoading = true
        do {
            defer { _isLoading = false }
            _allUnits = try await client.fetchAllUnits()
            loadFromStorage()
        } catch {
            _toastMessage = ToastMessage(message: "ユニットの取得に失敗しました", style: .error)
        }
    }

    private func loadFromStorage() {
        let savedNames = filteredUnitsStorage.load()
        _selectedUnitNames = Set(savedNames)
    }

    func toggleSelection(_ unit: GameUnit) {
        if _selectedUnitNames.contains(unit.name) {
            _selectedUnitNames.remove(unit.name)
        } else {
            _selectedUnitNames.insert(unit.name)
        }
    }

    func clearAll() {
        _selectedUnitNames.removeAll()
    }

    func save() {
        filteredUnitsStorage.save(names: Array(_selectedUnitNames))
    }
}

// MARK: - FilterUnitsViewModelOutputs
extension FilterUnitsViewModel: FilterUnitsViewModelOutputs {
    var allUnits: [GameUnit] {
        _allUnits
    }

    var selectedUnitNames: Set<String> {
        _selectedUnitNames
    }

    var isLoading: Bool {
        _isLoading
    }

    var toastMessage: Binding<ToastMessage?> {
        Binding(
            get: { self._toastMessage },
            set: { self._toastMessage = $0 }
        )
    }
}
