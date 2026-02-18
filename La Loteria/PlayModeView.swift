//
//  PlayModeView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import SwiftUI

struct PlayModeView: View {
    @State private var gameManager: PlayModeGameManager
    let settings: SettingsManager
    let speechManager: SpeechManager
    let onExit: () -> Void          // Back to mode selection

    // Pre-game setup state
    @State private var gameStarted = false
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedWinConditions: Set<WinCondition> = [.fullBoard]
    @State private var showScorePopup = false
    @State private var showRivalPopup = false

    private var calledCardIDs: Set<Int> {
        Set(gameManager.calledCards.map(\.id))
    }

    init(settings: SettingsManager, speechManager: SpeechManager, onExit: @escaping () -> Void) {
        self.settings = settings
        self.speechManager = speechManager
        self.onExit = onExit
        _gameManager = State(initialValue: PlayModeGameManager())
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

            if gameStarted {
                gameView
            } else {
                setupView
            }

            // Result overlay
            if gameManager.gameOver, let result = gameManager.gameResult {
                GameResultView(
                    result: result,
                    settings: settings,
                    playerWins: gameManager.playerWins,
                    cpuWins: gameManager.cpuWins,
                    draws: gameManager.drawCount,
                    onRematch: {
                        gameManager.rematch()
                        gameManager.difficulty = selectedDifficulty
                        gameManager.winConditions = selectedWinConditions
                        gameManager.speechManager = speechManager
                        gameManager.play()
                    },
                    onMainMenu: {
                        onExit()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.gameOver)
        .onAppear {
            gameManager.speechManager = speechManager
        }
    }

    // MARK: - Setup View (Difficulty + Win Conditions)

    private var setupView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.white.opacity(0.2)))
                    }

                    Spacer()

                    Text("Lotería")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Difficulty picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(settings.localize(.chooseDifficulty))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    VStack(spacing: 6) {
                        ForEach(Difficulty.allCases) { diff in
                            difficultyRow(diff)
                        }
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.15)))
                .padding(.horizontal, 20)

                // Win condition picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(settings.localize(.chooseWinCondition))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    VStack(spacing: 6) {
                        ForEach(WinCondition.allCases) { condition in
                            winConditionRow(condition)
                        }
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.15)))
                .padding(.horizontal, 20)

                // Score display if there's history
                if gameManager.playerWins + gameManager.cpuWins + gameManager.drawCount > 0 {
                    scorePanel
                        .padding(.horizontal, 20)
                }

                // Start button
                Button {
                    startGame()
                } label: {
                    Text(settings.localize(.startGame))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedWinConditions.isEmpty ? .gray.opacity(0.4) : .green.opacity(0.85))
                        )
                }
                .disabled(selectedWinConditions.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 0) {
            // ── Nav bar ──────────────────────────────────────────────
            HStack {
                // Exit
                Button {
                    gameManager.pause()
                    gameStarted = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white.opacity(0.2)))
                }

                Spacer()

                // Rival
                Button {
                    if selectedDifficulty == .easy { gameManager.pause() }
                    showRivalPopup = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "person.fill.viewfinder")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Rival")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.2)))
                }
                .sheet(isPresented: $showRivalPopup, onDismiss: {
                    if selectedDifficulty == .easy { gameManager.play() }
                }) {
                    rivalSheetContent
                }

                Spacer()

                // Score badge
                Button { showScorePopup = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(gameManager.playerWins)-\(gameManager.drawCount)-\(gameManager.cpuWins)")
                            .font(.system(size: 12, weight: .bold))
                            .monospacedDigit()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.2)))
                }
                .popover(isPresented: $showScorePopup, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                    scorePopupContent
                }

                // Pause / Resume
                Button {
                    gameManager.isPlaying ? gameManager.pause() : gameManager.play()
                } label: {
                    Image(systemName: gameManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // ── Compact card + timer panel ────────────────────────────
            compactCardPanel
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            // ── Board fills all remaining space ───────────────────────
            Text(settings.localize(.markYourCard))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.bottom, 2)

            LoteriaBoardView(
                board: gameManager.playerBoard,
                title: settings.localize(.yourBoard),
                isInteractive: true,
                calledCardIDs: calledCardIDs,
                onTap: { cellID in gameManager.playerTap(cellID: cellID) }
            )
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Subviews

    /// Slim horizontal card panel — thumbnail left, name + riddle vertically centered right, timer pinned to bottom
    private var compactCardPanel: some View {
        Group {
            if let card = gameManager.currentCard {
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 14) {
                        // Thumbnail — vertically centered in the HStack
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                            .shadow(radius: 5, y: 3)

                        // Name + riddle, centered vertically
                        VStack(alignment: .leading, spacing: 5) {
                            Text(card.name)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text(card.riddle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        // Progress counter top-right
                        Text("\(gameManager.currentCardIndex + 1)/54")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.65))
                            .monospacedDigit()
                            .alignmentGuide(.top) { d in d[.top] }
                    }

                    // Timer bar pinned to the bottom of the panel
                    HStack(spacing: 8) {
                        ProgressView(value: gameManager.timerProgress)
                            .tint(.green.opacity(0.9))
                            .background(.white.opacity(0.25))
                            .clipShape(Capsule())

                        Text(String(format: "%.1fs", selectedDifficulty.interval * (1.0 - gameManager.timerProgress)))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                            .monospacedDigit()
                            .frame(width: 34, alignment: .trailing)
                    }
                    .padding(.top, 10)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.15)))

            } else {
                // Pre-game idle state
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.8))
                        .symbolEffect(.pulse)
                        .frame(width: 60)

                    Text(settings.localize(.pressPlayToStart))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.15)))
            }
        }
    }

    private var scorePanel: some View {
        HStack(spacing: 0) {
            scoreTile(
                label: settings.localize(.wins),
                value: gameManager.playerWins,
                color: .green,
                icon: "person.fill"
            )

            Divider().frame(height: 40).overlay(.white.opacity(0.3))

            scoreTile(
                label: settings.localize(.draws),
                value: gameManager.drawCount,
                color: .yellow,
                icon: "equal"
            )

            Divider().frame(height: 40).overlay(.white.opacity(0.3))

            scoreTile(
                label: settings.localize(.losses),
                value: gameManager.cpuWins,
                color: .red,
                icon: "desktopcomputer"
            )
        }
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.15)))
    }

    private func scoreTile(label: String, value: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color.opacity(0.8))

            Text("\(value)")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(color)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    private var rivalSheetContent: some View {
        NavigationStack {
            ZStack {
                // Background matches game theme
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.4, blue: 0.9),
                        Color(red: 0.1, green: 0.6, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Easy mode notice banner
                    if selectedDifficulty == .easy {
                        HStack(spacing: 8) {
                            Image(systemName: "pause.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("Game paused while viewing rival")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(.black.opacity(0.25)))
                        .padding(.top, 8)
                    }

                    // CPU progress counter
                    HStack {
                        Spacer()
                        Label(
                            "\(gameManager.cpuBoard.markedCount)/16 marked",
                            systemImage: "desktopcomputer"
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                    }

                    // CPU board (read-only)
                    LoteriaBoardView(
                        board: gameManager.cpuBoard,
                        title: settings.localize(.cpuBoard),
                        isInteractive: false,
                        calledCardIDs: calledCardIDs,
                        onTap: nil
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Rival's Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        showRivalPopup = false
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var scorePopupContent: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Text(settings.localize(.score))
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button {
                    showScorePopup = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }

            // Score tiles row
            HStack(spacing: 16) {
                scorePopupTile(
                    label: settings.localize(.wins),
                    value: gameManager.playerWins,
                    color: .green,
                    icon: "person.fill"
                )
                scorePopupTile(
                    label: settings.localize(.draws),
                    value: gameManager.drawCount,
                    color: .yellow,
                    icon: "equal"
                )
                scorePopupTile(
                    label: settings.localize(.losses),
                    value: gameManager.cpuWins,
                    color: .red,
                    icon: "desktopcomputer"
                )
            }
        }
        .padding(20)
        .presentationCompactAdaptation(.popover)
        .frame(minWidth: 260)
    }

    private func scorePopupTile(label: String, value: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text("\(value)")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(color)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - Setup Rows

    private func difficultyRow(_ diff: Difficulty) -> some View {
        let isSelected = selectedDifficulty == diff

        let label: String = {
            switch diff {
            case .easy:   return settings.localize(.easy)
            case .medium: return settings.localize(.medium)
            case .hard:   return settings.localize(.hard)
            }
        }()

        let desc: String = {
            switch diff {
            case .easy:   return settings.localize(.easyDesc)
            case .medium: return settings.localize(.mediumDesc)
            case .hard:   return settings.localize(.hardDesc)
            }
        }()

        let icon: String = {
            switch diff {
            case .easy:   return "tortoise.fill"
            case .medium: return "hare.fill"
            case .hard:   return "bolt.fill"
            }
        }()

        let accentColor: Color = {
            switch diff {
            case .easy:   return .green
            case .medium: return .yellow
            case .hard:   return .red
            }
        }()

        return Button {
            selectedDifficulty = diff
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(accentColor)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(isSelected ? 0.3 : 0.12))
            )
        }
    }

    private func winConditionRow(_ condition: WinCondition) -> some View {
        let isSelected = selectedWinConditions.contains(condition)

        let label: String = {
            switch condition {
            case .row:       return settings.localize(.winRow)
            case .column:    return settings.localize(.winColumn)
            case .diagonal:  return settings.localize(.winDiagonal)
            case .fullBoard: return settings.localize(.winFullBoard)
            }
        }()

        let icon: String = {
            switch condition {
            case .row:       return "rectangle.split.3x1"
            case .column:    return "rectangle.split.1x2"
            case .diagonal:  return "arrow.up.right"
            case .fullBoard: return "square.grid.4x3.fill"
            }
        }()

        return Button {
            if isSelected {
                selectedWinConditions.remove(condition)
            } else {
                selectedWinConditions.insert(condition)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 26)

                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .green : .white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(isSelected ? 0.25 : 0.1))
            )
        }
    }

    // MARK: - Actions

    private func startGame() {
        gameManager.difficulty = selectedDifficulty
        gameManager.winConditions = selectedWinConditions
        gameManager.speechManager = speechManager
        gameManager.startNewGame()
        gameStarted = true
        gameManager.play()
    }
}
