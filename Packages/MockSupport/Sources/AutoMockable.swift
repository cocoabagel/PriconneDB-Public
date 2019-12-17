// swiftlint:disable all
//
//  AutoMockable.swift
//  MockSupport
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

/// Sourceryによるmock自動生成のためのマーカープロトコル
/// このプロトコルに準拠したプロトコルは、自動的にMockクラスが生成されます
public protocol AutoMockable {}

/// Sendable対応のmock生成のためのマーカープロトコル
/// AutoMockableと併用することで、スレッドセーフなMockクラスが生成されます
public protocol AutoMockableSendable: AutoMockable {}
// swiftlint:enable all
