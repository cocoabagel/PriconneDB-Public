//
//  ViewBuildable.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import Entity
import SharedViews
import SwiftUI

/// Feature間の画面遷移を抽象化するプロトコル
@MainActor
public protocol ViewBuildable: Sendable {
    /// AttackTeamListViewを生成
    func buildAttackTeamListView(
        defenseTeam: DefenseTeam,
        onShowToast: ((ToastMessage) -> Void)?
    ) -> AnyView

    /// CreateDefenseTeamViewを生成
    func buildCreateDefenseTeamView(
        onSave: @escaping () -> Void
    ) -> AnyView

    /// CreateAttackTeamSelectUnitsViewを生成（NavigationStack含む）
    func buildCreateAttackTeamView(
        defenseTeamId: String,
        onSave: @escaping () -> Void
    ) -> AnyView

    /// FilterUnitsViewを生成（NavigationStack含む）
    func buildFilterUnitsView() -> AnyView
}
