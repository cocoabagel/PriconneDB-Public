//
//  AttackTeamListBuilderView.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import Entity
import SharedViews
import SwiftUI

/// AttackTeamListViewのBuilderラッパー
public struct AttackTeamListBuilderView: View {
    @Environment(\.viewBuilder)
    private var viewBuilder

    private let defenseTeam: DefenseTeam
    private let onShowToast: ((ToastMessage) -> Void)?

    public init(defenseTeam: DefenseTeam, onShowToast: ((ToastMessage) -> Void)? = nil) {
        self.defenseTeam = defenseTeam
        self.onShowToast = onShowToast
    }

    public var body: some View {
        if let viewBuilder {
            viewBuilder.buildAttackTeamListView(
                defenseTeam: defenseTeam,
                onShowToast: onShowToast
            )
        } else {
            EmptyView()
        }
    }
}
