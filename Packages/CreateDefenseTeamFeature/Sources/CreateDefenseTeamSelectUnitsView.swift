//
//  CreateDefenseTeamSelectUnitsView.swift
//  CreateDefenseTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import FilterUnitsFeature
import Resources
import SharedViews
import SwiftUI

struct CreateDefenseTeamSelectUnitsView: View {
    @State private var viewModel: CreateDefenseTeamSelectUnitsViewModelType = CreateDefenseTeamSelectUnitsViewModel()
    @Environment(\.dismiss)
    private var dismiss
    @State private var showFilterView = false

    private let onSave: () -> Void

    init(onSave: @escaping () -> Void) {
        self.onSave = onSave
    }

    var body: some View {
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
        .navigationTitle("防衛チーム作成")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image.close
                        .fontWeight(.medium)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16.0) {
                    Button {
                        showFilterView = true
                    } label: {
                        Image(systemName: viewModel.outputs.hasFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.title2)
                    }

                    Button("保存") {
                        Task {
                            let success = await viewModel.inputs.saveTeam()
                            if success {
                                onSave()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.outputs.canProceed || viewModel.outputs.isSaving)
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
        .toast(viewModel.outputs.toastMessage)
    }
}
