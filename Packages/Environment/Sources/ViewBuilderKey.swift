//
//  ViewBuilderKey.swift
//  Environment
//
//  Created by Kazutoshi Baba on 2025/12/09.
//

import SwiftUI

/// ViewBuildable用のEnvironmentKey
public struct ViewBuilderKey: EnvironmentKey {
    public static let defaultValue: (any ViewBuildable)? = nil
}

public extension EnvironmentValues {
    /// ViewBuildableを取得・設定するためのEnvironment
    var viewBuilder: (any ViewBuildable)? {
        get { self[ViewBuilderKey.self] }
        set { self[ViewBuilderKey.self] = newValue }
    }
}
