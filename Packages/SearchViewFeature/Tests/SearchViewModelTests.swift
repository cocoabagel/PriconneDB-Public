//
//  SearchViewModelTests.swift
//  SearchViewFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Foundation
import Mocks
@testable import SearchViewFeature
import Testing

@Suite
@MainActor
struct SearchViewModelTests {
    // MARK: - Setup

    let mockClient: FireStoreClientProtocolMock
    let mockSelectedStorage: SelectedUnitsStorageProtocolMock
    let mockFilteredStorage: FilteredUnitsStorageProtocolMock
    let sut: SearchViewModelType

    init() {
        mockClient = FireStoreClientProtocolMock()
        mockSelectedStorage = SelectedUnitsStorageProtocolMock()
        mockFilteredStorage = FilteredUnitsStorageProtocolMock()

        // デフォルトの戻り値を設定
        mockSelectedStorage.loadReturnValue = []
        mockFilteredStorage.loadReturnValue = []

        sut = SearchViewModel(
            client: mockClient,
            selectedUnitsStorage: mockSelectedStorage,
            filteredUnitsStorage: mockFilteredStorage
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

    @Test
    func fetchUnitsEmpty() async {
        // Given
        mockClient.fetchAllUnitsReturnValue = []

        // When
        await sut.inputs.fetchUnits()

        // Then
        #expect(sut.outputs.filteredUnits.isEmpty)
    }

    @Test
    func fetchUnitsWithFilter() async {
        // Given
        let units = [
            GameUnit.stub(name: "ペコリーヌ"),
            GameUnit.stub(name: "コッコロ"),
            GameUnit.stub(name: "キャル")
        ]
        mockClient.fetchAllUnitsReturnValue = units
        mockFilteredStorage.loadReturnValue = ["ペコリーヌ", "コッコロ"]

        let sutWithFilter = SearchViewModel(
            client: mockClient,
            selectedUnitsStorage: mockSelectedStorage,
            filteredUnitsStorage: mockFilteredStorage
        )

        // When
        await sutWithFilter.inputs.fetchUnits()

        // Then
        #expect(sutWithFilter.outputs.filteredUnits.count == 2)
        #expect(sutWithFilter.outputs.filteredUnits.contains { $0.name == "ペコリーヌ" })
        #expect(sutWithFilter.outputs.filteredUnits.contains { $0.name == "コッコロ" })
        #expect(!sutWithFilter.outputs.filteredUnits.contains { $0.name == "キャル" })
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
        #expect(mockSelectedStorage.saveUnitsCallsCount == 1)
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
        #expect(sut.outputs.selectedUnits.isEmpty)
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
        #expect(mockSelectedStorage.saveUnitsCallsCount == 2) // toggle + remove
    }

    // MARK: - hasFilter

    @Test
    func hasFilter() {
        // Given
        mockFilteredStorage.loadReturnValue = ["ペコリーヌ"]

        // Then
        #expect(sut.outputs.hasFilter == true)
    }

    @Test
    func hasFilterEmpty() {
        // Given
        mockFilteredStorage.loadReturnValue = []

        // Then
        #expect(sut.outputs.hasFilter == false)
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
