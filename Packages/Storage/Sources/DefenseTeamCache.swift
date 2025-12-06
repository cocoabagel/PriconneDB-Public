//
//  DefenseTeamCache.swift
//  Storage
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Foundation
import MockSupport
import SwiftData

public protocol DefenseTeamCacheProtocol: AutoMockableSendable {
    func save(_ teams: [DefenseTeam]) async throws
    func fetchAll() async -> [DefenseTeam]
    func search(memberNames: [String]) async -> [DefenseTeam]
    func delete(id: String) async throws
}

@ModelActor
public actor DefenseTeamCache: DefenseTeamCacheProtocol {
    public func save(_ teams: [DefenseTeam]) throws {
        for team in teams {
            guard let cached = CachedDefenseTeam(from: team) else { continue }

            // 既存のデータを更新または新規作成
            let id = team.id
            let descriptor = FetchDescriptor<CachedDefenseTeam>(
                predicate: #Predicate { $0.id == id }
            )

            if let existing = try? modelContext.fetch(descriptor).first {
                existing.attackTypeRaw = cached.attackTypeRaw
                existing.membersData = cached.membersData
                existing.winsData = cached.winsData
                existing.memberNames = cached.memberNames
                existing.created = cached.created
                existing.lastUpdated = cached.lastUpdated
                existing.cachedAt = Date()
            } else {
                modelContext.insert(cached)
            }
        }
        try modelContext.save()
    }

    public func fetchAll() -> [DefenseTeam] {
        let descriptor = FetchDescriptor<CachedDefenseTeam>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        guard let cached = try? modelContext.fetch(descriptor) else {
            return []
        }
        return cached.compactMap { $0.toDefenseTeam() }
    }

    /// memberNamesに含まれる全てのユニットを持つチームを検索（部分一致）
    public func search(memberNames: [String]) -> [DefenseTeam] {
        guard !memberNames.isEmpty else {
            return fetchAll()
        }

        let descriptor = FetchDescriptor<CachedDefenseTeam>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )

        guard let cached = try? modelContext.fetch(descriptor) else {
            return []
        }

        // メモリ上でフィルタリング（部分一致検索）
        let filtered = cached.filter { team in
            memberNames.allSatisfy { name in
                team.memberNames.contains(name)
            }
        }

        return filtered.compactMap { $0.toDefenseTeam() }
    }

    public func delete(id: String) throws {
        let descriptor = FetchDescriptor<CachedDefenseTeam>(
            predicate: #Predicate { $0.id == id }
        )
        if let cached = try? modelContext.fetch(descriptor).first {
            modelContext.delete(cached)
            try modelContext.save()
        }
    }
}

// MARK: - ModelContainer Factory
public extension DefenseTeamCache {
    static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([CachedDefenseTeam.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [config])
    }

    static func createInMemoryModelContainer() throws -> ModelContainer {
        let schema = Schema([CachedDefenseTeam.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}

// MARK: - NoOp Cache (Fallback)
/// キャッシュが利用できない場合のフォールバック実装
public actor NoOpDefenseTeamCache: DefenseTeamCacheProtocol {
    public init() {}

    public func save(_: [DefenseTeam]) throws {}
    public func fetchAll() -> [DefenseTeam] { [] }
    public func search(memberNames _: [String]) -> [DefenseTeam] { [] }
    public func delete(id _: String) throws {}
}
