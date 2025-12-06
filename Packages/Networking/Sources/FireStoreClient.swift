//
//  FireStoreClient.swift
//  Networking
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import Entity
import FirebaseFirestore
import MockSupport

public protocol FireStoreClientProtocol: AutoMockableSendable, Sendable {
    func fetchAllUnits() async throws -> [GameUnit]
    func fetchDefenseTeams(refresh: Bool) async throws -> [DefenseTeam]
    func createDefenseTeam(members: [GameUnit]) async throws
    func deleteDefenseTeam(id: String) async throws
    func fetchDefenseTeam(id: String) async throws -> DefenseTeam?
    func createAttackTeam(defenseTeamID: String, members: [GameUnit], remarks: String) async throws
    func deleteAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws
    func likeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws
    func dislikeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws
}

public actor FireStoreClient: FireStoreClientProtocol {
    private let db: Firestore
    private let pageSize: Int
    private let startDay = Calendar.current.date(
        from: DateComponents(year: 2_024, month: 1, day: 1)
    )
    private var lastDocument: DocumentSnapshot?

    public init(
        db: Firestore = Firestore.firestore(),
        pageSize: Int = 50
    ) {
        self.db = db
        self.pageSize = pageSize
    }

    public func fetchAllUnits() async throws -> [GameUnit] {
        let query = db.collection("units")
            .order(by: "position", descending: false)
        return try await query.getDocuments().documents.compactMap(GameUnit.init(document:))
    }

    public func fetchDefenseTeams(refresh: Bool = false) async throws -> [DefenseTeam] {
        if refresh {
            lastDocument = nil
        }

        var query: Query = db.collection("teams")
            .whereField("lastUpdated", isGreaterThan: startDay as Any)
            .order(by: "lastUpdated", descending: true)
            .limit(to: pageSize)

        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        let snapshot = try await query.getDocuments()
        lastDocument = snapshot.documents.last

        return snapshot.documents.compactMap(DefenseTeam.init(document:))
    }

    public func createDefenseTeam(members: [GameUnit]) async throws {
        let sortedMembers = members.sorted { $0.position > $1.position }
        let now = Date()

        let data: [String: Any] = [
            "attackType": AttackType.defend.rawValue,
            "members": sortedMembers.map(\.toAnyObject),
            "wins": [],
            "created": Timestamp(date: now),
            "lastUpdated": Timestamp(date: now)
        ]

        try await db.collection("teams").addDocument(data: data)
    }

    public func deleteDefenseTeam(id: String) async throws {
        try await db.collection("teams").document(id).delete()
    }

    public func fetchDefenseTeam(id: String) async throws -> DefenseTeam? {
        let document = try await db.collection("teams").document(id).getDocument()
        guard document.exists else { return nil }

        return DefenseTeam(document: document)
    }

    public func createAttackTeam(defenseTeamID: String, members: [GameUnit], remarks: String) async throws {
        let sortedMembers = members.sorted { $0.position > $1.position }
        let now = Date()

        let attackTeamData: [String: Any] = [
            "attackType": AttackType.attack.rawValue,
            "members": sortedMembers.map(\.toAnyObject),
            "recommend": false,
            "likeCount": 0,
            "dislikeCount": 0,
            "remarks": remarks,
            "created": Timestamp(date: now),
            "lastUpdated": Timestamp(date: now)
        ]

        let teamRef = db.collection("teams").document(defenseTeamID)

        try await teamRef.updateData([
            "wins": FieldValue.arrayUnion([attackTeamData]),
            "lastUpdated": Timestamp(date: now)
        ])
    }

    public func deleteAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        let teamRef = db.collection("teams").document(defenseTeamID)
        let document = try await teamRef.getDocument()

        guard let wins = document.data()?["wins"] as? [[String: Any]] else { return }

        // membersの名前リストとcreatedで一致判定
        let targetMemberNames = attackTeam.members
            .sorted { $0.position > $1.position }
            .map(\.name)
        let targetCreated = Timestamp(date: attackTeam.created)

        let updatedWins = wins.filter { dict in
            guard
                let members = dict["members"] as? [[String: Any]],
                let created = dict["created"] as? Timestamp
            else { return true }
            let memberNames = members.compactMap { $0["name"] as? String }

            return !(memberNames == targetMemberNames && created.seconds == targetCreated.seconds)
        }

        try await teamRef.updateData([
            "wins": updatedWins,
            "lastUpdated": Timestamp(date: Date())
        ])
    }

    public func likeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        try await updateAttackTeamCount(
            defenseTeamID: defenseTeamID,
            attackTeam: attackTeam,
            field: "likeCount",
            increment: 1
        )
    }

    public func dislikeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        try await updateAttackTeamCount(
            defenseTeamID: defenseTeamID,
            attackTeam: attackTeam,
            field: "dislikeCount",
            increment: 1
        )
    }

    private func updateAttackTeamCount(
        defenseTeamID: String,
        attackTeam: AttackTeam,
        field: String,
        increment: Int
    ) async throws {
        let teamRef = db.collection("teams").document(defenseTeamID)
        let document = try await teamRef.getDocument()

        guard var wins = document.data()?["wins"] as? [[String: Any]] else { return }

        let targetMemberNames = attackTeam.members
            .sorted { $0.position > $1.position }
            .map(\.name)
        let targetCreated = Timestamp(date: attackTeam.created)

        for index in wins.indices {
            guard
                let members = wins[index]["members"] as? [[String: Any]],
                let created = wins[index]["created"] as? Timestamp
            else { continue }

            let memberNames = members.compactMap { $0["name"] as? String }
            if memberNames == targetMemberNames && created.seconds == targetCreated.seconds {
                let currentCount = wins[index][field] as? Int ?? 0
                wins[index][field] = currentCount + increment
                break
            }
        }

        try await teamRef.updateData([
            "wins": wins,
            "lastUpdated": Timestamp(date: Date())
        ])
    }
}
