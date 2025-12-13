//
//  PreviewBuilder.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import Entity
import SharedViews
import SwiftUI

/// Xcode Preview用のダミービルダー
public struct PreviewBuilder: ViewBuildable, Sendable {
    public init() {}

    public func buildAttackTeamListView(
        defenseTeam _: DefenseTeam,
        onShowToast _: ((ToastMessage) -> Void)?
    ) -> AnyView {
        AnyView(
            Text("AttackTeamListView Preview")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }

    public func buildCreateDefenseTeamView(
        onSave _: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            Text("CreateDefenseTeamView Preview")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }

    public func buildCreateAttackTeamView(
        defenseTeamId _: String,
        onSave _: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            NavigationStack {
                Text("CreateAttackTeamView Preview")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
    }

    public func buildFilterUnitsView() -> AnyView {
        AnyView(
            NavigationStack {
                Text("FilterUnitsView Preview")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
    }
}

/// PreviewProvider用の拡張
public extension PreviewProvider {
    /// Preview用のBuilderを取得
    static var previewBuilder: some ViewBuildable { PreviewBuilder() }
}
