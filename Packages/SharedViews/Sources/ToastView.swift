//
//  ToastView.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/30.
//

import SwiftUI

// MARK: - ToastStyle

public enum ToastStyle {
    case error
    case info
    case success
    case warning

    var iconName: String {
        switch self {
        case .error:
            "xmark.circle.fill"

        case .info:
            "info.circle.fill"

        case .success:
            "checkmark.circle.fill"

        case .warning:
            "exclamationmark.triangle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .error:
            .red

        case .info:
            .blue

        case .success:
            .green

        case .warning:
            .orange
        }
    }
}

// MARK: - ToastMessage

public struct ToastMessage: Equatable, Identifiable {
    public let id = UUID()
    public let message: String
    public let style: ToastStyle

    public init(message: String, style: ToastStyle = .error) {
        self.message = message
        self.style = style
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - ToastView

struct ToastView: View {
    let message: ToastMessage
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -100.0
    @State private var opacity: Double = 0.0

    init(message: ToastMessage, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: 12.0) {
            Image(systemName: message.style.iconName)
                .font(.title3)
                .foregroundStyle(message.style.iconColor)

            Text(message.message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .shadow(color: .black.opacity(0.15), radius: 8.0, y: 4.0)
        .padding(.horizontal, 16.0)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismiss()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -20.0 {
                        dismiss()
                    }
                }
        )
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = -100.0
            opacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - ToastModifier

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    ToastView(message: toast) {
                        self.toast = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: toast)
    }
}

// MARK: - View Extension

public extension View {
    func toast(_ toast: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}
