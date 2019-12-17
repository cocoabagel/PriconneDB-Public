//
//  AttackTeamRow.swift
//  AttackTeamListFeature
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import Entity
import SharedViews
import SwiftUI

struct AttackTeamRow: View {
    private let attackTeam: AttackTeam
    private let onLike: () -> Void
    private let onDislike: () -> Void

    init(attackTeam: AttackTeam, onLike: @escaping () -> Void, onDislike: @escaping () -> Void) {
        self.attackTeam = attackTeam
        self.onLike = onLike
        self.onDislike = onDislike
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter
    }()

    var body: some View {
        VStack(alignment: .center, spacing: 8.0) {
            TeamRow(members: attackTeam.members)
            metadataRow
            remarksText
        }
    }
}

private extension AttackTeamRow {
    var metadataRow: some View {
        HStack {
            Text(Self.dateFormatter.string(from: attackTeam.created))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 16.0) {
                Button {
                    onDislike()
                } label: {
                    Label("\(attackTeam.dislikeCount)", systemImage: "hand.thumbsdown")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.orange)

                Button {
                    onLike()
                } label: {
                    Label("\(attackTeam.likeCount)", systemImage: "hand.thumbsup")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.green)
            }
            .font(.subheadline)
        }
        .padding(.horizontal, 16.0)
    }

    @ViewBuilder var remarksText: some View {
        if !attackTeam.remarks.isEmpty {
            Text(attackTeam.remarks)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16.0)
        }
    }
}
