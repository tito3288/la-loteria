//
//  GameResultView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import SwiftUI

struct GameResultView: View {
    let result: PlayModeResult
    let settings: SettingsManager
    let playerWins: Int
    let cpuWins: Int
    let draws: Int
    let onRematch: () -> Void
    let onMainMenu: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { } // absorb taps

            VStack(spacing: 28) {
                // Emoji / Icon
                Text(resultEmoji)
                    .font(.system(size: 72))

                // Title
                Text(resultTitle)
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Scoreboard
                VStack(spacing: 4) {
                    Text(settings.localize(.score))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .textCase(.uppercase)

                    HStack(spacing: 32) {
                        scoreColumn(label: settings.localize(.wins), value: playerWins, color: .green)
                        scoreColumn(label: settings.localize(.losses), value: cpuWins, color: .red)
                        scoreColumn(label: settings.localize(.draws), value: draws, color: .yellow)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.15))
                )

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onRematch) {
                        Text(settings.localize(.playAgain))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(rematchColor)
                            )
                    }

                    Button(action: onMainMenu) {
                        Text(settings.localize(.backToMenu))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.2))
                            )
                    }
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: resultGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30, y: 10)
            )
            .padding(.horizontal, 24)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    // MARK: - Helpers

    private var resultEmoji: String {
        switch result {
        case .playerWins: return "🎉"
        case .cpuWins:    return "😔"
        case .draw:       return "🤝"
        }
    }

    private var resultTitle: String {
        switch result {
        case .playerWins: return settings.localize(.youWin)
        case .cpuWins:    return settings.localize(.youLose)
        case .draw:       return settings.localize(.draw)
        }
    }

    private var resultGradient: [Color] {
        switch result {
        case .playerWins:
            return [Color(red: 0.1, green: 0.6, blue: 0.3), Color(red: 0.05, green: 0.4, blue: 0.2)]
        case .cpuWins:
            return [Color(red: 0.55, green: 0.1, blue: 0.15), Color(red: 0.35, green: 0.05, blue: 0.1)]
        case .draw:
            return [Color(red: 0.2, green: 0.35, blue: 0.65), Color(red: 0.1, green: 0.2, blue: 0.5)]
        }
    }

    private var rematchColor: Color {
        switch result {
        case .playerWins: return .green.opacity(0.8)
        case .cpuWins:    return .red.opacity(0.7)
        case .draw:       return .blue.opacity(0.7)
        }
    }

    private func scoreColumn(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(color)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
