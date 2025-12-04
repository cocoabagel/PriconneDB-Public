//
//  DefenseTeamListView.swift
//  DefenseTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import AttackTeamListFeature
import CreateDefenseTeamFeature
import Entity
import Resources
import SharedViews
import SwiftUI

public struct DefenseTeamListView: View {
    @State private var viewModel: DefenseTeamListViewModelType = DefenseTeamListViewModel()
    @State private var showCreateTeam = false
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if horizontalSizeClass == .regular {
                    iPadLayout
                } else {
                    iPhoneLayout
                }
            }
            .navigationTitle("防衛")
            .navigationDestination(for: DefenseTeam.self) { team in
                AttackTeamListView(defenseTeam: team) { toast in
                    viewModel.inputs.showToast(toast)
                }
            }
            .refreshable {
                await viewModel.inputs.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateTeam = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showCreateTeam) {
                CreateDefenseTeamView {
                    viewModel.inputs.showSaveSuccessToast()
                }
            }
            .task {
                await viewModel.inputs.fetchInitial()
            }
            .onChange(of: showCreateTeam) { _, isShowing in
                if !isShowing {
                    Task {
                        await viewModel.inputs.refresh()
                    }
                }
            }
        }
        .toast(viewModel.outputs.toastMessage)
    }
}

private extension DefenseTeamListView {
    /// 先読み込みを開始する残りアイテム数
    var prefetchThreshold: Int { 5 }

    var iPhoneLayout: some View {
        List {
            teamsSection
            loadingSection
        }
        .listStyle(.plain)
    }

    var iPadLayout: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16.0) {
                ForEach(viewModel.outputs.defenseTeams) { team in
                    NavigationLink(value: team) {
                        TeamRow(members: team.members)
                            .padding(.vertical, 12.0)
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.inputs.deleteTeam(team)
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                    .onAppear {
                        prefetchIfNeeded(currentTeam: team, allTeams: viewModel.outputs.defenseTeams)
                    }
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.top, 8.0)

            if viewModel.outputs.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .refreshable {
            await viewModel.inputs.refresh()
        }
    }

    var teamsSection: some View {
        let teams = viewModel.outputs.defenseTeams

        return ForEach(teams) { team in
            TeamRow(members: team.members)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(NavigationLink(value: team) { EmptyView() }.opacity(0))
                .listRowInsets(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.inputs.deleteTeam(team)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
                .onAppear {
                    prefetchIfNeeded(currentTeam: team, allTeams: teams)
                }
        }
    }

    func prefetchIfNeeded(currentTeam: DefenseTeam, allTeams: [DefenseTeam]) {
        guard let currentIndex = allTeams.firstIndex(where: { $0.id == currentTeam.id }) else {
            return
        }

        let remainingItems = allTeams.count - currentIndex - 1
        if remainingItems <= prefetchThreshold {
            Task {
                await viewModel.inputs.fetchMore()
            }
        }
    }

    @ViewBuilder var loadingSection: some View {
        if viewModel.outputs.isLoading {
            ProgressView()
                .padding()
        }
    }
}

#Preview {
    DefenseTeamListView()
}
