//
//  CreateDefenseTeamView.swift
//  CreateDefenseTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import SwiftUI

public struct CreateDefenseTeamView: View {
    @State private var viewModel = CreateDefenseTeamViewModel()
    @Environment(\.dismiss)
    private var dismiss

    private let onSave: () -> Void

    public init(onSave: @escaping () -> Void = {}) {
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            CreateDefenseTeamSelectUnitsView(viewModel: viewModel) {
                onSave()
                dismiss()
            }
        }
    }
}

#Preview {
    CreateDefenseTeamView()
}
