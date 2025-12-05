//
//  AttackTeamListViewModelTests.swift
//  AttackTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

@testable import AttackTeamListFeature
import Entity
import Foundation
import Mocks
import Testing

@Suite
@MainActor
struct AttackTeamListViewModelTests {
    // MARK: - Setup

    let mockClient: FireStoreClientProtocolMock
    let defenseTeam: DefenseTeam
    let sut: AttackTeamListViewModelType

    init() {
        mockClient = FireStoreClientProtocolMock()
        defenseTeam = DefenseTeam.stub(id: "test-defense-id")
        sut = AttackTeamListViewModel(defenseTeam: defenseTeam, client: mockClient)
    }

    // MARK: - Initial State

    @Test
    func initialState() {
        // Then
        #expect(sut.outputs.defenseTeam.id == "test-defense-id")
        #expect(sut.outputs.isLoading == false)
    }

    // MARK: - fetchAttackTeams

    @Test
    func fetchAttackTeams() async {
        // Given
        let attackTeams = [AttackTeam.stub(id: "attack-1"), AttackTeam.stub(id: "attack-2")]
        let updatedDefenseTeam = DefenseTeam.stub(id: "test-defense-id", wins: attackTeams)
        mockClient.fetchDefenseTeamIdReturnValue = updatedDefenseTeam

        // When
        await sut.inputs.fetchAttackTeams()

        // Then
        #expect(mockClient.fetchDefenseTeamIdCallsCount == 1)
        #expect(mockClient.fetchDefenseTeamIdReceivedId == "test-defense-id")
        #expect(sut.outputs.attackTeams.count == 2)
        #expect(sut.outputs.isLoading == false)
    }

    @Test
    func fetchAttackTeamsNotFound() async {
        // Given
        mockClient.fetchDefenseTeamIdReturnValue = nil

        // When
        await sut.inputs.fetchAttackTeams()

        // Then
        #expect(mockClient.fetchDefenseTeamIdCallsCount == 1)
    }

    // MARK: - refresh

    @Test
    func refresh() async {
        // Given
        let attackTeams = [AttackTeam.stub(id: "attack-1")]
        let updatedDefenseTeam = DefenseTeam.stub(id: "test-defense-id", wins: attackTeams)
        mockClient.fetchDefenseTeamIdReturnValue = updatedDefenseTeam

        // When
        await sut.inputs.refresh()

        // Then
        #expect(mockClient.fetchDefenseTeamIdCallsCount == 1)
        #expect(sut.outputs.attackTeams.count == 1)
    }

    // MARK: - deleteAttackTeam

    @Test
    func deleteAttackTeam() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-delete")

        // When
        await sut.inputs.deleteAttackTeam(attackTeam)

        // Then
        #expect(mockClient.deleteAttackTeamDefenseTeamIDAttackTeamCallsCount == 1)
        #expect(mockClient.deleteAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.defenseTeamID == "test-defense-id")
        #expect(mockClient.deleteAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.attackTeam.id == "attack-to-delete")
    }

    // MARK: - likeAttackTeam

    @Test
    func likeAttackTeam() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-like")
        mockClient.fetchDefenseTeamIdReturnValue = defenseTeam

        // When
        await sut.inputs.likeAttackTeam(attackTeam)

        // Then
        #expect(mockClient.likeAttackTeamDefenseTeamIDAttackTeamCallsCount == 1)
        #expect(mockClient.likeAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.defenseTeamID == "test-defense-id")
        #expect(mockClient.likeAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.attackTeam.id == "attack-to-like")
        // refresh が呼ばれることを確認
        #expect(mockClient.fetchDefenseTeamIdCallsCount == 1)
    }

    // MARK: - dislikeAttackTeam

    @Test
    func dislikeAttackTeam() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-dislike")
        mockClient.fetchDefenseTeamIdReturnValue = defenseTeam

        // When
        await sut.inputs.dislikeAttackTeam(attackTeam)

        // Then
        #expect(mockClient.dislikeAttackTeamDefenseTeamIDAttackTeamCallsCount == 1)
        #expect(mockClient.dislikeAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.defenseTeamID == "test-defense-id")
        #expect(mockClient.dislikeAttackTeamDefenseTeamIDAttackTeamReceivedArguments?.attackTeam.id == "attack-to-dislike")
        // refresh が呼ばれることを確認
        #expect(mockClient.fetchDefenseTeamIdCallsCount == 1)
    }

    // MARK: - toastMessage

    @Test
    func fetchAttackTeamsError() async {
        // Given
        mockClient.fetchDefenseTeamIdThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.fetchAttackTeams()

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "データの取得に失敗しました")
    }

    @Test
    func deleteAttackTeamError() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-delete")
        mockClient.deleteAttackTeamDefenseTeamIDAttackTeamThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.deleteAttackTeam(attackTeam)

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "削除に失敗しました")
    }

    @Test
    func likeAttackTeamError() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-like")
        mockClient.likeAttackTeamDefenseTeamIDAttackTeamThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.likeAttackTeam(attackTeam)

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "評価に失敗しました")
    }

    @Test
    func dislikeAttackTeamError() async {
        // Given
        let attackTeam = AttackTeam.stub(id: "attack-to-dislike")
        mockClient.dislikeAttackTeamDefenseTeamIDAttackTeamThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.dislikeAttackTeam(attackTeam)

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "評価に失敗しました")
    }
}
