// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Entity
import Foundation
import Networking
import Storage

public final class FireStoreClientProtocolMock: FireStoreClientProtocol, @unchecked Sendable {
    private let lock = NSLock()

    public init() {}

    // MARK: - fetchAllUnits

    public var fetchAllUnitsThrowableError: Error?
    public var fetchAllUnitsCallsCount = 0
    public var fetchAllUnitsReturnValue: [GameUnit]!

    public func fetchAllUnits() async throws -> [GameUnit] {
        if let error = fetchAllUnitsThrowableError {
            throw error
        }
        fetchAllUnitsCallsCount += 1
        return fetchAllUnitsReturnValue
    }

    // MARK: - fetchDefenseTeams

    public var fetchDefenseTeamsRefreshThrowableError: Error?
    public var fetchDefenseTeamsRefreshCallsCount = 0
    public var fetchDefenseTeamsRefreshReceivedRefresh: Bool?
    public var fetchDefenseTeamsRefreshReturnValue: [DefenseTeam]!

    public func fetchDefenseTeams(refresh: Bool) async throws -> [DefenseTeam] {
        if let error = fetchDefenseTeamsRefreshThrowableError {
            throw error
        }
        fetchDefenseTeamsRefreshCallsCount += 1
        fetchDefenseTeamsRefreshReceivedRefresh = refresh
        return fetchDefenseTeamsRefreshReturnValue
    }

    // MARK: - createDefenseTeam

    public var createDefenseTeamMembersThrowableError: Error?
    public var createDefenseTeamMembersCallsCount = 0
    public var createDefenseTeamMembersReceivedMembers: [GameUnit]?

    public func createDefenseTeam(members: [GameUnit]) async throws {
        if let error = createDefenseTeamMembersThrowableError {
            throw error
        }
        createDefenseTeamMembersCallsCount += 1
        createDefenseTeamMembersReceivedMembers = members
    }

    // MARK: - deleteDefenseTeam

    public var deleteDefenseTeamIdThrowableError: Error?
    public var deleteDefenseTeamIdCallsCount = 0
    public var deleteDefenseTeamIdReceivedId: String?

    public func deleteDefenseTeam(id: String) async throws {
        if let error = deleteDefenseTeamIdThrowableError {
            throw error
        }
        deleteDefenseTeamIdCallsCount += 1
        deleteDefenseTeamIdReceivedId = id
    }

    // MARK: - fetchDefenseTeam

    public var fetchDefenseTeamIdThrowableError: Error?
    public var fetchDefenseTeamIdCallsCount = 0
    public var fetchDefenseTeamIdReceivedId: String?
    public var fetchDefenseTeamIdReturnValue: DefenseTeam?

    public func fetchDefenseTeam(id: String) async throws -> DefenseTeam? {
        if let error = fetchDefenseTeamIdThrowableError {
            throw error
        }
        fetchDefenseTeamIdCallsCount += 1
        fetchDefenseTeamIdReceivedId = id
        return fetchDefenseTeamIdReturnValue
    }

    // MARK: - createAttackTeam

    public var createAttackTeamDefenseTeamIDMembersRemarksThrowableError: Error?
    public var createAttackTeamDefenseTeamIDMembersRemarksCallsCount = 0
    public var createAttackTeamDefenseTeamIDMembersRemarksReceivedArguments: (defenseTeamID: String, members: [GameUnit], remarks: String)?

    public func createAttackTeam(defenseTeamID: String, members: [GameUnit], remarks: String) async throws {
        if let error = createAttackTeamDefenseTeamIDMembersRemarksThrowableError {
            throw error
        }
        createAttackTeamDefenseTeamIDMembersRemarksCallsCount += 1
        createAttackTeamDefenseTeamIDMembersRemarksReceivedArguments = (defenseTeamID: defenseTeamID, members: members, remarks: remarks)
    }

    // MARK: - deleteAttackTeam

    public var deleteAttackTeamDefenseTeamIDAttackTeamThrowableError: Error?
    public var deleteAttackTeamDefenseTeamIDAttackTeamCallsCount = 0
    public var deleteAttackTeamDefenseTeamIDAttackTeamReceivedArguments: (defenseTeamID: String, attackTeam: AttackTeam)?

    public func deleteAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        if let error = deleteAttackTeamDefenseTeamIDAttackTeamThrowableError {
            throw error
        }
        deleteAttackTeamDefenseTeamIDAttackTeamCallsCount += 1
        deleteAttackTeamDefenseTeamIDAttackTeamReceivedArguments = (defenseTeamID: defenseTeamID, attackTeam: attackTeam)
    }

    // MARK: - likeAttackTeam

    public var likeAttackTeamDefenseTeamIDAttackTeamThrowableError: Error?
    public var likeAttackTeamDefenseTeamIDAttackTeamCallsCount = 0
    public var likeAttackTeamDefenseTeamIDAttackTeamReceivedArguments: (defenseTeamID: String, attackTeam: AttackTeam)?

    public func likeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        if let error = likeAttackTeamDefenseTeamIDAttackTeamThrowableError {
            throw error
        }
        likeAttackTeamDefenseTeamIDAttackTeamCallsCount += 1
        likeAttackTeamDefenseTeamIDAttackTeamReceivedArguments = (defenseTeamID: defenseTeamID, attackTeam: attackTeam)
    }

    // MARK: - dislikeAttackTeam

    public var dislikeAttackTeamDefenseTeamIDAttackTeamThrowableError: Error?
    public var dislikeAttackTeamDefenseTeamIDAttackTeamCallsCount = 0
    public var dislikeAttackTeamDefenseTeamIDAttackTeamReceivedArguments: (defenseTeamID: String, attackTeam: AttackTeam)?

    public func dislikeAttackTeam(defenseTeamID: String, attackTeam: AttackTeam) async throws {
        if let error = dislikeAttackTeamDefenseTeamIDAttackTeamThrowableError {
            throw error
        }
        dislikeAttackTeamDefenseTeamIDAttackTeamCallsCount += 1
        dislikeAttackTeamDefenseTeamIDAttackTeamReceivedArguments = (defenseTeamID: defenseTeamID, attackTeam: attackTeam)
    }
}
