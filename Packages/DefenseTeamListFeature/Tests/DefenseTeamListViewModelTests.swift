//
//  DefenseTeamListViewModelTests.swift
//  DefenseTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

@testable import DefenseTeamListFeature
import Entity
import Foundation
import Mocks
import Testing

@Suite
@MainActor
struct DefenseTeamListViewModelTests {
    // MARK: - Setup

    let mockClient: FireStoreClientProtocolMock
    let mockCache: DefenseTeamCacheProtocolMock
    let mockStorage: SelectedUnitsStorageProtocolMock
    let sut: DefenseTeamListViewModel

    init() {
        mockClient = FireStoreClientProtocolMock()
        mockCache = DefenseTeamCacheProtocolMock()
        mockStorage = SelectedUnitsStorageProtocolMock()

        // デフォルトの戻り値を設定
        mockStorage.loadSortedNamesReturnValue = []
        mockCache.fetchAllReturnValue = []
        mockCache.searchMemberNamesReturnValue = []

        sut = DefenseTeamListViewModel(
            client: mockClient,
            cache: mockCache,
            selectedUnitsStorage: mockStorage
        )
    }

    // MARK: - fetchInitial

    @Test
    func fetchInitial() async {
        // Given
        let teams = [DefenseTeam.stub(id: "1"), DefenseTeam.stub(id: "2")]
        mockClient.fetchDefenseTeamsRefreshReturnValue = teams

        // When
        await sut.inputs.fetchInitial()

        // Then
        #expect(mockClient.fetchDefenseTeamsRefreshCallsCount == 1)
        #expect(mockClient.fetchDefenseTeamsRefreshReceivedRefresh == true)
        #expect(mockCache.saveCallsCount == 1)
        #expect(sut.outputs.defenseTeams.count == 2)
        #expect(sut.outputs.hasMorePages == true)
    }

    @Test
    func fetchInitialEmpty() async {
        // Given
        mockClient.fetchDefenseTeamsRefreshReturnValue = []

        // When
        await sut.inputs.fetchInitial()

        // Then
        #expect(sut.outputs.defenseTeams.isEmpty)
        #expect(sut.outputs.hasMorePages == false)
    }

    @Test
    func fetchInitialWithFilter() async {
        // Given
        mockStorage.loadSortedNamesReturnValue = ["ペコリーヌ"]
        mockClient.fetchDefenseTeamsRefreshReturnValue = [DefenseTeam.stub()]
        let filteredTeams = [DefenseTeam.stub(id: "filtered")]
        mockCache.searchMemberNamesReturnValue = filteredTeams

        let sutWithFilter = DefenseTeamListViewModel(
            client: mockClient,
            cache: mockCache,
            selectedUnitsStorage: mockStorage
        )

        // When
        await sutWithFilter.inputs.fetchInitial()

        // Then
        #expect(mockCache.searchMemberNamesCallsCount == 1)
        #expect(mockCache.searchMemberNamesReceivedMemberNames == ["ペコリーヌ"])
        #expect(sutWithFilter.outputs.defenseTeams.count == 1)
        #expect(sutWithFilter.outputs.defenseTeams.first?.id == "filtered")
    }

    // MARK: - fetchMore

    @Test
    func fetchMore() async {
        // Given
        mockClient.fetchDefenseTeamsRefreshReturnValue = [DefenseTeam.stub(id: "1")]
        await sut.inputs.fetchInitial()

        let moreTeams = [DefenseTeam.stub(id: "2")]
        mockClient.fetchDefenseTeamsRefreshReturnValue = moreTeams

        // When
        await sut.inputs.fetchMore()

        // Then
        #expect(mockClient.fetchDefenseTeamsRefreshCallsCount == 2)
        #expect(sut.outputs.defenseTeams.count == 2)
    }

    @Test
    func fetchMoreEmpty() async {
        // Given
        mockClient.fetchDefenseTeamsRefreshReturnValue = [DefenseTeam.stub()]
        await sut.inputs.fetchInitial()

        mockClient.fetchDefenseTeamsRefreshReturnValue = []

        // When
        await sut.inputs.fetchMore()

        // Then
        #expect(sut.outputs.hasMorePages == false)
    }

    // MARK: - deleteTeam

    @Test
    func deleteTeam() async {
        // Given
        let team = DefenseTeam.stub(id: "to-delete")
        mockClient.fetchDefenseTeamsRefreshReturnValue = [team]
        await sut.inputs.fetchInitial()

        // When
        await sut.inputs.deleteTeam(team)

        // Then
        #expect(mockClient.deleteDefenseTeamIdCallsCount == 1)
        #expect(mockClient.deleteDefenseTeamIdReceivedId == "to-delete")
        #expect(mockCache.deleteIdCallsCount == 1)
        #expect(sut.outputs.defenseTeams.isEmpty)
    }

    // MARK: - toastMessage

    @Test
    func fetchInitialError() async {
        // Given
        mockClient.fetchDefenseTeamsRefreshThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.fetchInitial()

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "データの取得に失敗しました")
    }

    @Test
    func fetchMoreError() async {
        // Given
        mockClient.fetchDefenseTeamsRefreshReturnValue = [DefenseTeam.stub()]
        await sut.inputs.fetchInitial()
        mockClient.fetchDefenseTeamsRefreshThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.fetchMore()

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "追加データの取得に失敗しました")
    }

    @Test
    func deleteTeamError() async {
        // Given
        let team = DefenseTeam.stub(id: "to-delete")
        mockClient.fetchDefenseTeamsRefreshReturnValue = [team]
        await sut.inputs.fetchInitial()
        mockClient.deleteDefenseTeamIdThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.deleteTeam(team)

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "削除に失敗しました")
    }
}
