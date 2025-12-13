//
//  CreateAttackTeamBuilderView.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import SwiftUI

/// CreateAttackTeamSelectUnitsViewのBuilderラッパー（NavigationStack含む）
public struct CreateAttackTeamBuilderView: View {
    @Environment(\.viewBuilder)
    private var viewBuilder

    private let defenseTeamId: String
    private let onSave: () -> Void

    public init(defenseTeamId: String, onSave: @escaping () -> Void) {
        self.defenseTeamId = defenseTeamId
        self.onSave = onSave
    }

    public var body: some View {
        if let viewBuilder {
            viewBuilder.buildCreateAttackTeamView(
                defenseTeamId: defenseTeamId,
                onSave: onSave
            )
        } else {
            EmptyView()
        }
    }
}
