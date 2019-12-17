//
//  MainTabView.swift
//  AppFeature
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import DefenseTeamListFeature
import SearchViewFeature
import SwiftUI

@MainActor
public struct MainTabView: View {
    @State private var selectedTab: TabType = .defense
    @State private var showSplash = false
    @State private var showLaunchSplash = true
    @State private var splashIcon: String = "shield.fill"
    @State private var splashColor: Color = .blue

    public init() {}

    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("防衛", systemImage: "shield.fill", value: .defense) {
                    DefenseTeamListView()
                }

                Tab(value: .search, role: .search) {
                    SearchView()
                }
            }
            .onChange(of: selectedTab) { _, newValue in
                triggerSplash(for: newValue)
            }

            if showSplash {
                TabSplashView(icon: splashIcon, color: splashColor)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if showLaunchSplash {
                LaunchSplashView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunchSplash = false
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    private func triggerSplash(for tab: TabType) {
        switch tab {
        case .defense:
            splashIcon = "shield.fill"
            splashColor = .blue

        case .search:
            splashIcon = "magnifyingglass"
            splashColor = .purple
        }

        withAnimation(.easeOut(duration: 0.1)) {
            showSplash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.2)) {
                showSplash = false
            }
        }
    }
}

// MARK: - TabType

private enum TabType: Hashable {
    case defense
    case search
}

// MARK: - TabSplashView

private struct TabSplashView: View {
    let icon: String
    let color: Color

    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.3)
                .transition(.opacity)

            // リップルエフェクト
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0.0)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)

            // 2つ目のリップル
            Circle()
                .stroke(color.opacity(0.5), lineWidth: 3.0)
                .scaleEffect(rippleScale * 0.8)
                .opacity(rippleOpacity)

            // 中央のアイコン
            Image(systemName: icon)
                .font(.system(size: 80.0, weight: .bold))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.white, color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.8), radius: 20.0)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                iconScale = 1.2
                iconOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.5)) {
                rippleScale = 3.0
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                rippleOpacity = 0.0
            }

            withAnimation(.easeOut(duration: 0.2).delay(0.4)) {
                iconScale = 0.8
                iconOpacity = 0.0
            }
        }
    }
}

// MARK: - LaunchSplashView

private struct LaunchSplashView: View {
    let onComplete: () -> Void

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 20.0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringRotation: Double = 0.0
    @State private var backgroundOpacity: Double = 1.0
    @State private var particleOpacity: Double = 0.0

    private let accentColor = Color.blue

    var body: some View {
        ZStack {
            backgroundGradient
            particlesView.opacity(particleOpacity)
            mainContent
        }
        .onAppear {
            startAnimation()
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(backgroundOpacity)
    }

    private var mainContent: some View {
        VStack(spacing: 24.0) {
            logoSection
            titleSection
        }
    }

    private var logoSection: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(0.0),
                            accentColor.opacity(0.5),
                            accentColor
                        ]),
                        center: .center
                    ),
                    lineWidth: 3.0
                )
                .frame(width: 140.0, height: 140.0)
                .scaleEffect(ringScale)
                .rotationEffect(.degrees(ringRotation))

            Image(systemName: "shield.fill")
                .font(.system(size: 60.0, weight: .bold))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.white, accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accentColor.opacity(0.8), radius: 20.0)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 8.0) {
            Text("PriconneDB")
                .font(.system(size: 32.0, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("アリーナ編成データベース")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .opacity(titleOpacity)
        .offset(y: titleOffset)
    }

    private var particlesView: some View {
        GeometryReader { geometry in
            ForEach(0 ..< 20, id: \.self) { _ in
                Circle()
                    .fill(accentColor.opacity(Double.random(in: 0.2 ... 0.5)))
                    .frame(width: CGFloat.random(in: 4.0 ... 8.0))
                    .position(
                        x: CGFloat.random(in: 0 ... geometry.size.width),
                        y: CGFloat.random(in: 0 ... geometry.size.height)
                    )
                    .blur(radius: 1.0)
            }
        }
    }

    private func startAnimation() {
        // ロゴ登場
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // リング回転開始
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            ringRotation = 360.0
        }

        withAnimation(.easeOut(duration: 0.8)) {
            ringScale = 1.0
        }

        // パーティクル表示
        withAnimation(.easeIn(duration: 0.5).delay(0.2)) {
            particleOpacity = 1.0
        }

        // タイトル登場
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            titleOpacity = 1.0
            titleOffset = 0.0
        }

        // 完了後にフェードアウト
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                backgroundOpacity = 0.0
                logoOpacity = 0.0
                titleOpacity = 0.0
                particleOpacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onComplete()
            }
        }
    }
}

#Preview {
    MainTabView()
}
