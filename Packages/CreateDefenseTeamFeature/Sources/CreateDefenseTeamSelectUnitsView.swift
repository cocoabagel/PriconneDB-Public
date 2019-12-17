//
//  CreateDefenseTeamSelectUnitsView.swift
//  CreateDefenseTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import SharedViews
import SwiftUI

struct CreateDefenseTeamSelectUnitsView: View {
    @Bindable var viewModel: CreateDefenseTeamViewModel
    @Environment(\.dismiss)
    private var dismiss
    let onSave: () -> Void

    var body: some View {
        UnitsGridView(
            units: viewModel.outputs.allUnits,
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
                Button("保存") {
                    Task {
                        let success = await viewModel.inputs.saveTeam()
                        if success {
                            onSave()
                        }
                    }
                }
                .disabled(!viewModel.outputs.canProceed || viewModel.outputs.isSaving)
            }
        }
        .task {
            await viewModel.inputs.fetchUnits()
        }
        .toast(viewModel.outputs.toastMessage)
    }
}
