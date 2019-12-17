//
//  SearchViewModel.swift
//  SearchViewFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import Networking
import SharedViews
import Storage
import SwiftUI

@MainActor
protocol SearchViewModelInputs {
    func fetchUnits() async
    func applyFilter()
    func toggleSelection(_ unit: GameUnit)
    func removeSelection(_ unit: GameUnit)
}

@MainActor
protocol SearchViewModelOutputs {
    var filteredUnits: [GameUnit] { get }
    var selectedUnits: [GameUnit] { get }
    var isLoading: Bool { get }
    var hasFilter: Bool { get }
    var toastMessage: Binding<ToastMessage?> { get }
}

@MainActor
protocol SearchViewModelType: SearchViewModelInputs, SearchViewModelOutputs {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

@MainActor
@Observable
final class SearchViewModel: SearchViewModelType {
    private let client: FireStoreClientProtocol
    private let selectedUnitsStorage: SelectedUnitsStorageProtocol
    private let filteredUnitsStorage: FilteredUnitsStorageProtocol
    private let maxSelection = 5

    private var _allUnits: [GameUnit] = []
    private var _filteredUnits: [GameUnit] = []
    private var _selectedUnits: [GameUnit] = []
    private var _isLoading = false
    private var _toastMessage: ToastMessage?

    var inputs: SearchViewModelInputs { self }
    var outputs: SearchViewModelOutputs { self }

    init(
        client: FireStoreClientProtocol = FireStoreClient(),
        selectedUnitsStorage: SelectedUnitsStorageProtocol = SelectedUnitsStorage(),
        filteredUnitsStorage: FilteredUnitsStorageProtocol = FilteredUnitsStorage()
    ) {
        self.client = client
        self.selectedUnitsStorage = selectedUnitsStorage
        self.filteredUnitsStorage = filteredUnitsStorage
    }
}

// MARK: - SearchViewModelInputs
extension SearchViewModel: SearchViewModelInputs {
    func fetchUnits() async {
        guard !_isLoading else { return }

        _isLoading = true
        do {
            defer { _isLoading = false }
            _allUnits = try await client.fetchAllUnits()
            applyFilter()
            loadFromStorage()
        } catch {
            _toastMessage = ToastMessage(message: "ユニットの取得に失敗しました", style: .error)
        }
    }

    func applyFilter() {
        let filterNames = Set(filteredUnitsStorage.load())
        if filterNames.isEmpty {
            _filteredUnits = _allUnits
        } else {
            _filteredUnits = _allUnits.filter { filterNames.contains($0.name) }
        }
    }

    private func loadFromStorage() {
        let savedUnits = selectedUnitsStorage.load()
        _selectedUnits = savedUnits.compactMap { savedUnit in
            _filteredUnits.first { $0.name == savedUnit.name }
        }
    }

    func toggleSelection(_ unit: GameUnit) {
        if let index = selectedUnits.firstIndex(of: unit) {
            _selectedUnits.remove(at: index)
        } else if selectedUnits.count < maxSelection {
            _selectedUnits.append(unit)
        }
        saveToStorage()
    }

    func removeSelection(_ unit: GameUnit) {
        _selectedUnits.removeAll { $0 == unit }
        saveToStorage()
    }

    private func saveToStorage() {
        let units = _selectedUnits.map { SelectedUnit(name: $0.name, position: $0.position) }
        selectedUnitsStorage.save(units: units)
    }
}

// MARK: - SearchViewModelOutputs
extension SearchViewModel: SearchViewModelOutputs {
    var filteredUnits: [GameUnit] {
        _filteredUnits
    }

    var selectedUnits: [GameUnit] {
        _selectedUnits
    }

    var isLoading: Bool {
        _isLoading
    }

    var hasFilter: Bool {
        !filteredUnitsStorage.load().isEmpty
    }

    var toastMessage: Binding<ToastMessage?> {
        Binding(
            get: { self._toastMessage },
            set: { self._toastMessage = $0 }
        )
    }
}
