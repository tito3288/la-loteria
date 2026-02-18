//
//  ModeSelectionView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import SwiftUI

struct ModeSelectionView: View {
    @State private var settings = SettingsManager()
    @State private var speechManager = SpeechManager()
    @State private var selectedMode: GameMode? = nil
    @State private var showSettings = false

    enum GameMode {
        case caller
        case play
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.9),
                    Color(red: 0.1, green: 0.6, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch selectedMode {
            case .caller:
                ContentView(settings: settings, speechManager: speechManager) {
                    selectedMode = nil
                }
            case .play:
                PlayModeView(settings: settings, speechManager: speechManager) {
                    selectedMode = nil
                }
            case nil:
                selectionView
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings, speechManager: speechManager, isPresented: $showSettings)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedMode)
    }

    // MARK: - Mode Selection Screen

    private var selectionView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Lotería")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)

            Spacer()

            // Tagline
            Text(settings.localize(.chooseMode))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            // Mode Cards
            VStack(spacing: 20) {
                modeCard(
                    mode: .caller,
                    icon: "mic.fill",
                    title: settings.localize(.callerMode),
                    description: settings.localize(.callerModeDesc),
                    accentColor: Color(red: 0.95, green: 0.6, blue: 0.1),
                    gradientColors: [Color(red: 0.95, green: 0.55, blue: 0.05), Color(red: 0.85, green: 0.35, blue: 0.05)]
                )

                modeCard(
                    mode: .play,
                    icon: "gamecontroller.fill",
                    title: settings.localize(.playMode),
                    description: settings.localize(.playModeDesc),
                    accentColor: Color(red: 0.4, green: 0.85, blue: 0.5),
                    gradientColors: [Color(red: 0.1, green: 0.65, blue: 0.3), Color(red: 0.05, green: 0.45, blue: 0.2)]
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Mode Card

    private func modeCard(
        mode: GameMode,
        icon: String,
        title: String,
        description: String,
        accentColor: Color,
        gradientColors: [Color]
    ) -> some View {
        Button {
            selectedMode = mode
        } label: {
            HStack(spacing: 20) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.18))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            )
        }
    }
}

#Preview {
    ModeSelectionView()
}
