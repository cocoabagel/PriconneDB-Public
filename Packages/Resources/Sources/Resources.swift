//
//  Resources.swift
//  Resources
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import SwiftUI

public enum Resources {
    public static let bundle: Bundle = .module
}

// MARK: - Color
public extension Color {
    static let appAccent = Color("AccentColor", bundle: Resources.bundle)
}

// MARK: - Image
public extension Image {
    static let close = Image("Close", bundle: Resources.bundle)
    static let placeholder = Image("Placeholder", bundle: Resources.bundle)
    static let smallFilledStar = Image("smallFlledStar", bundle: Resources.bundle)
    static let smallFilled6Star = Image("smalliFlled6Star", bundle: Resources.bundle)
    static let uniqueEquipment = Image("uniqueEquipment", bundle: Resources.bundle)
}
