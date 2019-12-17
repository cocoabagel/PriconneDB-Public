//
//  SearchView.swift
//  SearchViewFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import FilterUnitsFeature
import SharedViews
import SwiftUI

public struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showFilterView = false

    public init() {}

    public var body: some View {
        NavigationStack {
            UnitsGridView(
                units: viewModel.outputs.filteredUnits,
                selectedUnits: viewModel.outputs.selectedUnits
            ) { unit in
                viewModel.inputs.toggleSelection(unit)
            }
            .overlay(alignment: .bottom) {
                SelectedUnitsBar(selectedUnits: viewModel.outputs.selectedUnits) { unit in
                    viewModel.inputs.removeSelection(unit)
                }
            }
            .navigationTitle("絞り込みたいキャラを選んでください")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilterView = true
                    } label: {
                        Image(systemName: viewModel.outputs.hasFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showFilterView) {
                viewModel.inputs.applyFilter()
            } content: {
                NavigationStack {
                    FilterUnitsView()
                }
            }
            .task {
                await viewModel.inputs.fetchUnits()
            }
        }
        .toast(viewModel.outputs.toastMessage)
    }
}

#Preview {
    SearchView()
}
