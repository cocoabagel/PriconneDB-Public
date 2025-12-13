//
//  AppViewBuilder.swift
//  AppFeature
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import AttackTeamListFeature
import CreateAttackTeamFeature
import CreateDefenseTeamFeature
import Entity
import Environment
import FilterUnitsFeature
import SharedViews
import SwiftUI

/// アプリ全体で使用するViewBuilder
/// 各FeatureのViewを生成し、DIを行う
public struct AppViewBuilder: ViewBuildable, Sendable {
    public init() {}

    public func buildAttackTeamListView(
        defenseTeam: DefenseTeam,
        onShowToast: ((ToastMessage) -> Void)?
    ) -> AnyView {
        AnyView(AttackTeamListView(defenseTeam: defenseTeam, onShowToast: onShowToast))
    }

    public func buildCreateDefenseTeamView(
        onSave: @escaping () -> Void
    ) -> AnyView {
        AnyView(CreateDefenseTeamView(onSave: onSave))
    }

    public func buildCreateAttackTeamView(
        defenseTeamId: String,
        onSave: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            NavigationStack {
                CreateAttackTeamSelectUnitsView(defenseTeamId: defenseTeamId, onSave: onSave)
            }
        )
    }

    public func buildFilterUnitsView() -> AnyView {
        AnyView(
            NavigationStack {
                FilterUnitsView()
            }
        )
    }
}
