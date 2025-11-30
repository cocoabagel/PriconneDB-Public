//
//  DefenseTeamListViewModel.swift
//  DefenseTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import Entity
import Networking
import Observation
import SharedViews
import Storage
import SwiftUI

@MainActor
protocol DefenseTeamListViewModelInputs {
    func fetchInitial() async
    func fetchMore() async
    func refresh() async
    func deleteTeam(_ team: DefenseTeam) async
    func showSaveSuccessToast()
    func showToast(_ toast: ToastMessage)
}

@MainActor
protocol DefenseTeamListViewModelOutputs {
    var defenseTeams: [DefenseTeam] { get }
    var isLoading: Bool { get }
    var hasMorePages: Bool { get }
    var toastMessage: Binding<ToastMessage?> { get }
}

@MainActor
protocol DefenseTeamListViewModelType: DefenseTeamListViewModelInputs, DefenseTeamListViewModelOutputs {
    var inputs: DefenseTeamListViewModelInputs { get }
    var outputs: DefenseTeamListViewModelOutputs { get }
}

@MainActor
@Observable
final class DefenseTeamListViewModel: DefenseTeamListViewModelType {
    private var _defenseTeams: [DefenseTeam] = []
    private var _isLoading = false
    private var _hasMorePages = true
    private var _toastMessage: ToastMessage?

    var inputs: DefenseTeamListViewModelInputs { self }
    var outputs: DefenseTeamListViewModelOutputs { self }

    private let client: FireStoreClientProtocol
    nonisolated(unsafe) private let cache: DefenseTeamCacheProtocol
    private let selectedUnitsStorage: SelectedUnitsStorageProtocol

    init(
        client: FireStoreClientProtocol = FireStoreClient(),
        cache: DefenseTeamCacheProtocol? = nil,
        selectedUnitsStorage: SelectedUnitsStorageProtocol = SelectedUnitsStorage()
    ) {
        self.client = client
        self.cache = cache ?? (try? DefenseTeamCache(modelContainer: DefenseTeamCache.createModelContainer())) ?? Self.createFallbackCache()
        self.selectedUnitsStorage = selectedUnitsStorage
    }

    private static func createFallbackCache() -> DefenseTeamCacheProtocol {
        // フォールバック用のインメモリキャッシュ、失敗時はNoOpキャッシュを返す
        do {
            let container = try DefenseTeamCache.createInMemoryModelContainer()
            return DefenseTeamCache(modelContainer: container)
        } catch {
            return NoOpDefenseTeamCache()
        }
    }
}

// MARK: - DefenseTeamListViewModelInputs
extension DefenseTeamListViewModel: DefenseTeamListViewModelInputs {
    private var filterUnitNames: [String] {
        selectedUnitsStorage.loadSortedNames()
    }

    func fetchInitial() async {
        _isLoading = true
        do {
            defer { _isLoading = false }

            // Firestoreから取得
            let teams = try await client.fetchDefenseTeams(refresh: true)

            // キャッシュに保存
            try? await cache.save(teams)

            // フィルターがある場合はキャッシュから検索、なければそのまま表示
            if filterUnitNames.isEmpty {
                _defenseTeams = teams
            } else {
                _defenseTeams = await cache.search(memberNames: filterUnitNames)
            }
            _hasMorePages = !teams.isEmpty
        } catch {
            _toastMessage = ToastMessage(message: "データの取得に失敗しました", style: .error)
            // エラー時はキャッシュから取得を試みる
            if filterUnitNames.isEmpty {
                _defenseTeams = await cache.fetchAll()
            } else {
                _defenseTeams = await cache.search(memberNames: filterUnitNames)
            }
        }
    }

    func fetchMore() async {
        guard !isLoading, hasMorePages else { return }
        _isLoading = true
        do {
            defer { _isLoading = false }

            // Firestoreから追加取得
            let teams = try await client.fetchDefenseTeams(refresh: false)

            if teams.isEmpty {
                _hasMorePages = false
            } else {
                // キャッシュに保存
                try? await cache.save(teams)

                // フィルターがある場合はキャッシュから再検索
                if filterUnitNames.isEmpty {
                    _defenseTeams.append(contentsOf: teams)
                } else {
                    _defenseTeams = await cache.search(memberNames: filterUnitNames)
                }
            }
        } catch {
            _toastMessage = ToastMessage(message: "追加データの取得に失敗しました", style: .error)
        }
    }

    func refresh() async {
        _hasMorePages = true
        await fetchInitial()
    }

    func deleteTeam(_ team: DefenseTeam) async {
        do {
            try await client.deleteDefenseTeam(id: team.id)
            try? await cache.delete(id: team.id)
            _defenseTeams.removeAll { $0.id == team.id }
        } catch {
            _toastMessage = ToastMessage(message: "削除に失敗しました", style: .error)
        }
    }

    func showSaveSuccessToast() {
        _toastMessage = ToastMessage(message: "保存しました", style: .success)
    }

    func showToast(_ toast: ToastMessage) {
        _toastMessage = toast
    }
}

// MARK: - DefenseTeamListViewModelOutputs
extension DefenseTeamListViewModel: DefenseTeamListViewModelOutputs {
    var defenseTeams: [DefenseTeam] {
        _defenseTeams
    }

    var isLoading: Bool {
        _isLoading
    }

    var hasMorePages: Bool {
        _hasMorePages
    }

    var toastMessage: Binding<ToastMessage?> {
        Binding(
            get: { self._toastMessage },
            set: { self._toastMessage = $0 }
        )
    }
}
