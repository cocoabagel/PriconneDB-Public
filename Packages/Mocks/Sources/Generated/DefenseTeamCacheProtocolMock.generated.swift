// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Entity
import Foundation
import Networking
import Storage

public final class DefenseTeamCacheProtocolMock: DefenseTeamCacheProtocol, @unchecked Sendable {
    private let lock = NSLock()

    public init() {}

    // MARK: - save

    public var saveThrowableError: Error?
    public var saveCallsCount = 0
    public var saveReceivedTeams: [DefenseTeam]?

    public func save(_ teams: [DefenseTeam]) async throws {
        if let error = saveThrowableError {
            throw error
        }
        saveCallsCount += 1
        saveReceivedTeams = teams
    }

    // MARK: - fetchAll

    public var fetchAllCallsCount = 0
    public var fetchAllReturnValue: [DefenseTeam]!

    public func fetchAll() async -> [DefenseTeam] {
        fetchAllCallsCount += 1
        return fetchAllReturnValue
    }

    // MARK: - search

    public var searchMemberNamesCallsCount = 0
    public var searchMemberNamesReceivedMemberNames: [String]?
    public var searchMemberNamesReturnValue: [DefenseTeam]!

    public func search(memberNames: [String]) async -> [DefenseTeam] {
        searchMemberNamesCallsCount += 1
        searchMemberNamesReceivedMemberNames = memberNames
        return searchMemberNamesReturnValue
    }

    // MARK: - delete

    public var deleteIdThrowableError: Error?
    public var deleteIdCallsCount = 0
    public var deleteIdReceivedId: String?

    public func delete(id: String) async throws {
        if let error = deleteIdThrowableError {
            throw error
        }
        deleteIdCallsCount += 1
        deleteIdReceivedId = id
    }
}
