//
//  AttackTeamListView.swift
//  AttackTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import CreateAttackTeamFeature
import Entity
import Resources
import SharedViews
import SwiftUI

public struct AttackTeamListView: View {
    @State private var viewModel: AttackTeamListViewModel
    @State private var showCreateAttackTeam = false
    @Environment(\.dismiss)
    private var dismiss

    private let onShowToast: ((ToastMessage) -> Void)?

    public init(defenseTeam: DefenseTeam, onShowToast: ((ToastMessage) -> Void)? = nil) {
        viewModel = AttackTeamListViewModel(defenseTeam: defenseTeam)
        self.onShowToast = onShowToast
    }

    public var body: some View {
        List {
            attackTeamsSection
        }
        .listStyle(.plain)
        .navigationTitle("勝利")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.medium)
                }
            }

            ToolbarItem(placement: .principal) {
                defenseTeamHeader
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateAttackTeam = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showCreateAttackTeam) {
            NavigationStack {
                CreateAttackTeamSelectUnitsView(defenseTeamId: viewModel.outputs.defenseTeam.id) {
                    if let onShowToast {
                        onShowToast(ToastMessage(message: "保存しました", style: .success))
                    }
                    Task {
                        await viewModel.inputs.refresh()
                    }
                }
            }
        }
        .task {
            await viewModel.inputs.fetchAttackTeams()
        }
    }
}

// MARK: - Private Views
private extension AttackTeamListView {
    var defenseTeamHeader: some View {
        HStack(spacing: 4.0) {
            ForEach(viewModel.outputs.defenseTeam.members.sorted { $0.position > $1.position }, id: \.name) { member in
                UnitIconView(unit: member, size: 32.0, showStarRank: false)
            }
        }
    }

    var attackTeamsSection: some View {
        ForEach(viewModel.outputs.attackTeams) { attackTeam in
            AttackTeamRow(
                attackTeam: attackTeam,
                onLike: {
                    Task {
                        await viewModel.inputs.likeAttackTeam(attackTeam)
                    }
                },
                onDislike: {
                    Task {
                        await viewModel.inputs.dislikeAttackTeam(attackTeam)
                    }
                }
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowInsets(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    Task {
                        await viewModel.inputs.deleteAttackTeam(attackTeam)
                    }
                } label: {
                    Label("削除", systemImage: "trash")
                }
            }
        }
    }
}
