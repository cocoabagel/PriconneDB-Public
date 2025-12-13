//
//  FilterUnitsBuilderView.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import SwiftUI

/// FilterUnitsViewのBuilderラッパー（NavigationStack含む）
public struct FilterUnitsBuilderView: View {
    @Environment(\.viewBuilder)
    private var viewBuilder

    public init() {}

    public var body: some View {
        if let viewBuilder {
            viewBuilder.buildFilterUnitsView()
        } else {
            EmptyView()
        }
    }
}
