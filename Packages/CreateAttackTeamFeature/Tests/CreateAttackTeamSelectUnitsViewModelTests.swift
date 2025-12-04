//
//  CreateAttackTeamSelectUnitsViewModelTests.swift
//  CreateAttackTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

@testable import CreateAttackTeamFeature
import Entity
import Foundation
import Mocks
import Testing

@Suite
@MainActor
struct CreateAttackTeamSelectUnitsViewModelTests {
    // MARK: - Setup

    let mockClient: FireStoreClientProtocolMock
    let mockFilteredUnitsStorage: FilteredUnitsStorageProtocolMock
    let sut: CreateAttackTeamSelectUnitsViewModel

    init() {
        mockClient = FireStoreClientProtocolMock()
        mockFilteredUnitsStorage = FilteredUnitsStorageProtocolMock()
        mockFilteredUnitsStorage.loadReturnValue = []
        sut = CreateAttackTeamSelectUnitsViewModel(
            defenseTeamId: "test-defense-id",
            client: mockClient,
            filteredUnitsStorage: mockFilteredUnitsStorage
        )
    }

    // MARK: - fetchUnits

    @Test
    func fetchUnits() async {
        // Given
        let units = [GameUnit.stub(name: "ペコリーヌ"), GameUnit.stub(name: "コッコロ")]
        mockClient.fetchAllUnitsReturnValue = units

        // When
        await sut.inputs.fetchUnits()

        // Then
        #expect(mockClient.fetchAllUnitsCallsCount == 1)
        #expect(sut.outputs.filteredUnits.count == 2)
        #expect(sut.outputs.isLoading == false)
    }

    // MARK: - toggleSelection

    @Test
    func toggleSelectionAdd() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()

        // When
        sut.inputs.toggleSelection(unit)

        // Then
        #expect(sut.outputs.selectedUnits.count == 1)
        #expect(sut.outputs.selectedUnits.first?.name == "ペコリーヌ")
        #expect(sut.outputs.canProceed == true)
    }

    @Test
    func toggleSelectionRemove() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit)

        // When
        sut.inputs.toggleSelection(unit)

        // Then
        #expect(sut.outputs.selectedUnits.isEmpty)
        #expect(sut.outputs.canProceed == false)
    }

    @Test
    func toggleSelectionMaxLimit() async {
        // Given
        let units = (1 ... 6).map { GameUnit.stub(name: "Unit\($0)", position: $0) }
        mockClient.fetchAllUnitsReturnValue = units
        await sut.inputs.fetchUnits()

        // 5個選択
        for unit in units.prefix(5) {
            sut.inputs.toggleSelection(unit)
        }

        // When - 6個目を追加しようとする
        sut.inputs.toggleSelection(units[5])

        // Then - 最大5個のまま
        #expect(sut.outputs.selectedUnits.count == 5)
    }

    // MARK: - removeSelection

    @Test
    func removeSelection() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit)

        // When
        sut.inputs.removeSelection(unit)

        // Then
        #expect(sut.outputs.selectedUnits.isEmpty)
    }

    // MARK: - updateRemarks

    @Test
    func updateRemarks() {
        // When
        sut.inputs.updateRemarks("テスト備考")

        // Then
        #expect(sut.outputs.remarks == "テスト備考")
    }

    // MARK: - saveTeam

    @Test
    func saveTeamSuccess() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit)
        sut.inputs.updateRemarks("備考")

        // When
        let result = await sut.inputs.saveTeam()

        // Then
        #expect(result == true)
        #expect(mockClient.createAttackTeamDefenseTeamIDMembersRemarksCallsCount == 1)
        #expect(mockClient.createAttackTeamDefenseTeamIDMembersRemarksReceivedArguments?.defenseTeamID == "test-defense-id")
        #expect(mockClient.createAttackTeamDefenseTeamIDMembersRemarksReceivedArguments?.members.count == 1)
        #expect(mockClient.createAttackTeamDefenseTeamIDMembersRemarksReceivedArguments?.remarks == "備考")
    }

    @Test
    func saveTeamEmpty() async {
        // Given - 何も選択していない

        // When
        let result = await sut.inputs.saveTeam()

        // Then
        #expect(result == false)
        #expect(mockClient.createAttackTeamDefenseTeamIDMembersRemarksCallsCount == 0)
    }

    @Test
    func saveTeamError() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit)
        mockClient.createAttackTeamDefenseTeamIDMembersRemarksThrowableError = NSError(domain: "test", code: 0)

        // When
        let result = await sut.inputs.saveTeam()

        // Then
        #expect(result == false)
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "保存に失敗しました")
    }

    // MARK: - canProceed

    @Test
    func canProceedInitially() {
        // Then
        #expect(sut.outputs.canProceed == false)
    }

    // MARK: - toastMessage

    @Test
    func fetchUnitsError() async {
        // Given
        mockClient.fetchAllUnitsThrowableError = NSError(domain: "test", code: 0)

        // When
        await sut.inputs.fetchUnits()

        // Then
        #expect(sut.outputs.toastMessage.wrappedValue != nil)
        #expect(sut.outputs.toastMessage.wrappedValue?.message == "ユニットの取得に失敗しました")
    }
}
