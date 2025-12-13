//
//  CreateDefenseTeamBuilderView.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import SwiftUI

/// CreateDefenseTeamViewのBuilderラッパー
public struct CreateDefenseTeamBuilderView: View {
    @Environment(\.viewBuilder)
    private var viewBuilder

    private let onSave: () -> Void

    public init(onSave: @escaping () -> Void) {
        self.onSave = onSave
    }

    public var body: some View {
        if let viewBuilder {
            viewBuilder.buildCreateDefenseTeamView(onSave: onSave)
        } else {
            EmptyView()
        }
    }
}
