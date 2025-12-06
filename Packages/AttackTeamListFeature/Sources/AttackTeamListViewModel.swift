//
//  AttackTeamListViewModel.swift
//  AttackTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import Entity
import Networking
import Observation

@MainActor
protocol AttackTeamListViewModelInputs {
    func fetchAttackTeams() async
    func refresh() async
    func deleteAttackTeam(_ attackTeam: AttackTeam) async
    func likeAttackTeam(_ attackTeam: AttackTeam) async
    func dislikeAttackTeam(_ attackTeam: AttackTeam) async
}

@MainActor
protocol AttackTeamListViewModelOutputs {
    var defenseTeam: DefenseTeam { get }
    var attackTeams: [AttackTeam] { get }
    var errorMessage: String? { get }
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
    private var _errorMessage: String?

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
        _errorMessage = nil
        do {
            defer { _isLoading = false }

            if let team = try await client.fetchDefenseTeam(id: _defenseTeam.id) {
                _attackTeams = team.wins
            }
        } catch {
            _errorMessage = "データの取得に失敗しました"
        }
    }

    func refresh() async {
        await fetchAttackTeams()
    }

    func deleteAttackTeam(_ attackTeam: AttackTeam) async {
        _errorMessage = nil
        do {
            try await client.deleteAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
            await refresh()
        } catch {
            _errorMessage = "削除に失敗しました"
        }
    }

    func likeAttackTeam(_ attackTeam: AttackTeam) async {
        _errorMessage = nil
        do {
            try await client.likeAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
            await refresh()
        } catch {
            _errorMessage = "評価に失敗しました"
        }
    }

    func dislikeAttackTeam(_ attackTeam: AttackTeam) async {
        _errorMessage = nil
        do {
            try await client.dislikeAttackTeam(defenseTeamID: _defenseTeam.id, attackTeam: attackTeam)
            await refresh()
        } catch {
            _errorMessage = "評価に失敗しました"
        }
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

    var errorMessage: String? {
        _errorMessage
    }
}
