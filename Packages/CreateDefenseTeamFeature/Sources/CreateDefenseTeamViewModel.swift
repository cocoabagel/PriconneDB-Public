//
//  CreateDefenseTeamViewModel.swift
//  CreateDefenseTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import Networking
import Observation
import SharedViews
import Storage
import SwiftUI

@MainActor
protocol CreateDefenseTeamViewModelInputs {
    func fetchUnits() async
    func applyFilter()
    func toggleSelection(_ unit: GameUnit)
    func removeSelection(_ unit: GameUnit)
    func saveTeam() async -> Bool
}

@MainActor
protocol CreateDefenseTeamViewModelOutputs {
    var filteredUnits: [GameUnit] { get }
    var selectedUnits: [GameUnit] { get }
    var isLoading: Bool { get }
    var isSaving: Bool { get }
    var canProceed: Bool { get }
    var hasFilter: Bool { get }
    var toastMessage: Binding<ToastMessage?> { get }
}

@MainActor
protocol CreateDefenseTeamViewModelType: CreateDefenseTeamViewModelInputs, CreateDefenseTeamViewModelOutputs {
    var inputs: CreateDefenseTeamViewModelInputs { get }
    var outputs: CreateDefenseTeamViewModelOutputs { get }
}

@MainActor
@Observable
final class CreateDefenseTeamViewModel: CreateDefenseTeamViewModelType {
    private let client: FireStoreClientProtocol
    private let filteredUnitsStorage: FilteredUnitsStorageProtocol
    private let maxSelection = 5

    private var _allUnits: [GameUnit] = []
    private var _filteredUnits: [GameUnit] = []
    private var _selectedUnits: [GameUnit] = []
    private var _isLoading = false
    private var _isSaving = false
    private var _toastMessage: ToastMessage?

    var inputs: CreateDefenseTeamViewModelInputs { self }
    var outputs: CreateDefenseTeamViewModelOutputs { self }

    init(
        client: FireStoreClientProtocol = FireStoreClient(),
        filteredUnitsStorage: FilteredUnitsStorageProtocol = FilteredUnitsStorage()
    ) {
        self.client = client
        self.filteredUnitsStorage = filteredUnitsStorage
    }
}

// MARK: - CreateDefenseTeamViewModelInputs
extension CreateDefenseTeamViewModel: CreateDefenseTeamViewModelInputs {
    func fetchUnits() async {
        guard !_isLoading else { return }

        _isLoading = true
        do {
            defer { _isLoading = false }
            _allUnits = try await client.fetchAllUnits()
            applyFilter()
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

    func toggleSelection(_ unit: GameUnit) {
        if let index = _selectedUnits.firstIndex(of: unit) {
            _selectedUnits.remove(at: index)
        } else if _selectedUnits.count < maxSelection {
            _selectedUnits.append(unit)
        }
    }

    func removeSelection(_ unit: GameUnit) {
        _selectedUnits.removeAll { $0 == unit }
    }

    func saveTeam() async -> Bool {
        guard !_selectedUnits.isEmpty else { return false }
        _isSaving = true
        defer { _isSaving = false }

        do {
            try await client.createDefenseTeam(members: _selectedUnits)
            return true
        } catch {
            _toastMessage = ToastMessage(message: "保存に失敗しました", style: .error)
            return false
        }
    }
}

// MARK: - CreateDefenseTeamViewModelOutputs
extension CreateDefenseTeamViewModel: CreateDefenseTeamViewModelOutputs {
    var filteredUnits: [GameUnit] {
        _filteredUnits
    }

    var selectedUnits: [GameUnit] {
        _selectedUnits
    }

    var isLoading: Bool {
        _isLoading
    }

    var isSaving: Bool {
        _isSaving
    }

    var canProceed: Bool {
        !_selectedUnits.isEmpty
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
