//
//  FilterUnitsViewModelTests.swift
//  FilterUnitsFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
@testable import FilterUnitsFeature
import Foundation
import Mocks
import Testing

@Suite
@MainActor
struct FilterUnitsViewModelTests {
    // MARK: - Setup

    let mockClient: FireStoreClientProtocolMock
    let mockStorage: FilteredUnitsStorageProtocolMock
    let sut: FilterUnitsViewModelType

    init() {
        mockClient = FireStoreClientProtocolMock()
        mockStorage = FilteredUnitsStorageProtocolMock()

        // デフォルトの戻り値を設定
        mockStorage.loadReturnValue = []

        sut = FilterUnitsViewModel(
            client: mockClient,
            filteredUnitsStorage: mockStorage
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
        #expect(sut.outputs.allUnits.count == 2)
        #expect(sut.outputs.isLoading == false)
    }

    @Test
    func fetchUnitsLoadsFromStorage() async {
        // Given
        let units = [GameUnit.stub(name: "ペコリーヌ"), GameUnit.stub(name: "コッコロ")]
        mockClient.fetchAllUnitsReturnValue = units
        mockStorage.loadReturnValue = ["ペコリーヌ"]

        let sutWithStorage = FilterUnitsViewModel(
            client: mockClient,
            filteredUnitsStorage: mockStorage
        )

        // When
        await sutWithStorage.inputs.fetchUnits()

        // Then
        #expect(sutWithStorage.outputs.selectedUnitNames.contains("ペコリーヌ"))
        #expect(sutWithStorage.outputs.selectedUnitNames.count == 1)
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
        #expect(sut.outputs.selectedUnitNames.contains("ペコリーヌ"))
    }

    @Test
    func toggleSelectionRemove() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit) // 追加

        // When
        sut.inputs.toggleSelection(unit) // 削除

        // Then
        #expect(!sut.outputs.selectedUnitNames.contains("ペコリーヌ"))
    }

    // MARK: - clearAll

    @Test
    func clearAll() async {
        // Given
        let units = [GameUnit.stub(name: "ペコリーヌ"), GameUnit.stub(name: "コッコロ")]
        mockClient.fetchAllUnitsReturnValue = units
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(units[0])
        sut.inputs.toggleSelection(units[1])
        #expect(sut.outputs.selectedUnitNames.count == 2)

        // When
        sut.inputs.clearAll()

        // Then
        #expect(sut.outputs.selectedUnitNames.isEmpty)
    }

    // MARK: - save

    @Test
    func save() async {
        // Given
        let unit = GameUnit.stub(name: "ペコリーヌ")
        mockClient.fetchAllUnitsReturnValue = [unit]
        await sut.inputs.fetchUnits()
        sut.inputs.toggleSelection(unit)

        // When
        sut.inputs.save()

        // Then
        #expect(mockStorage.saveNamesCallsCount == 1)
        #expect(mockStorage.saveNamesReceivedNames?.contains("ペコリーヌ") == true)
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
