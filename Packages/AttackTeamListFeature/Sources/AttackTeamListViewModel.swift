//
//  AttackTeamListViewModel.swift
//  AttackTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import Entity
import Networking
import Observation
import SharedViews
import SwiftUI

@MainActor
protocol AttackTeamListViewModelInputs {
    func fetchAttackTeams() async
    func refresh() async
    func deleteAttackTeam(_ attackTeam: AttackTeam) async
    func likeAttackTeam(_ attackTeam: AttackTeam) async
    func dislikeAttackTeam(_ attackTeam: AttackTeam) async
    func showSaveSuccessToast()
}

@MainActor
protocol AttackTeamListViewModelOutputs {
    var defenseTeam: DefenseTeam { get }
    var attackTeams: [AttackTeam] { get }
    var isLoading: Bool { get }
    var toastMessage: Binding<ToastMessage?> { get }
}

@MainActor
protocol AttackTeamListViewModelType: AttackTeamListViewModelInputs, AttackTeamListViewModelOutputs {
    var inputs: AttackTeamListViewModelInputs { get }
    var outputs: AttackTeamListViewModelOutputs { get }
}

@MainActor
@Observable
final class AttackTeamListViewModel: AttackTeamListViewModelType {
    private let client: FireStoreClientProtocol
    private let _defenseTeam: DefenseTeam

    private var _attackTeams: [AttackTeam] = []
    private var _isLoading = false
    private var _toastMessage: ToastMessage?

    var inputs: AttackTeamListViewModelInputs { self }
    var outputs: AttackTeamListViewModelOutputs { self }

    init(defenseTeam: DefenseTeam, client: FireStoreClientProtocol = FireStoreClient()) {
        _defenseTeam = defenseTeam
        _attackTeams = defenseTeam.wins
        self.client = client
    }
}

// MARK: - AttackTeamListViewModelInputs
extension AttackTeamListViewModel: AttackTeamListViewModelInputs {
    func fetchAttackTeams() async {
        guard !_isLoading else { return }
        _isLoading = true
        do {
            defer { _isLoading = false }

            if let team = try await client.fetchDefenseTeam(id: _defenseTeam.id) {
                _attackTeams = team.wins
            }
        } catch {
            _toastMessage = ToastMessage(message: "データの取得に失敗しました", style: .error)
        }
    }

    func refresh() async {
        await fetchAttackTeams()
    }

    func deleteAttackTeam(_ attackTeam: AttackTeam) async {
        do {
            try await client.deleteAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
        } catch {
            _toastMessage = ToastMessage(message: "削除に失敗しました", style: .error)
        }
    }

    func likeAttackTeam(_ attackTeam: AttackTeam) async {
        do {
            try await client.likeAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
            await refresh()
        } catch {
            _toastMessage = ToastMessage(message: "評価に失敗しました", style: .error)
        }
    }

    func dislikeAttackTeam(_ attackTeam: AttackTeam) async {
        do {
            try await client.dislikeAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
            await refresh()
        } catch {
            _toastMessage = ToastMessage(message: "評価に失敗しました", style: .error)
        }
    }

    func showSaveSuccessToast() {
        _toastMessage = ToastMessage(message: "保存しました", style: .success)
    }
}

// MARK: - AttackTeamListViewModelOutputs
extension AttackTeamListViewModel: AttackTeamListViewModelOutputs {
    var defenseTeam: DefenseTeam {
        _defenseTeam
    }

    var attackTeams: [AttackTeam] {
        _attackTeams
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
