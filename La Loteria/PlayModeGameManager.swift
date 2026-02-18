//
//  PlayModeGameManager.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import Foundation
import SwiftUI

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Identifiable {
    case easy   = "easy"
    case medium = "medium"
    case hard   = "hard"

    var id: String { rawValue }

    /// Seconds between each card being called
    var interval: TimeInterval {
        switch self {
        case .easy:   return 8.0
        case .medium: return 5.0
        case .hard:   return 3.0
        }
    }

    /// Maximum random delay (seconds) before the CPU marks a matched card.
    /// This makes the CPU feel human — it doesn't mark instantly.
    var cpuMarkDelay: ClosedRange<Double> {
        switch self {
        case .easy:   return 0.8...2.0
        case .medium: return 0.5...1.5
        case .hard:   return 0.2...0.8
        }
    }
}

// MARK: - Game Result

enum PlayModeResult {
    case playerWins
    case cpuWins
    case draw
}

// MARK: - Play Mode Game Manager

@MainActor
@Observable
class PlayModeGameManager {

    // MARK: Boards
    var playerBoard: LoteriaBoardModel = .random()
    var cpuBoard: LoteriaBoardModel = .random()

    // MARK: Deck / Called Cards
    var deck: [LoteriaCard] = []
    var calledCards: [LoteriaCard] = []
    var currentCard: LoteriaCard?
    var currentCardIndex: Int = -1

    // MARK: Game Settings (set before starting)
    var difficulty: Difficulty = .medium
    var winConditions: Set<WinCondition> = [.row, .column, .diagonal, .fullBoard]

    // MARK: Playback State
    var isPlaying: Bool = false
    var timerProgress: Double = 0.0
    private var timeElapsed: TimeInterval = 0.0

    // MARK: Result
    var gameResult: PlayModeResult? = nil
    var gameOver: Bool = false

    // MARK: Persistent Score
    var playerWins: Int = 0
    var cpuWins: Int = 0
    var drawCount: Int = 0

    // MARK: Timers
    private var cardTimer: Timer?
    private var progressTimer: Timer?
    private var pausedTimeRemaining: TimeInterval = 0.0

    // MARK: Speech
    var speechManager: SpeechManager?

    // MARK: - Setup

    /// Call this when starting a fresh game (new boards, reshuffled deck).
    func startNewGame() {
        stopTimers()
        playerBoard = .random()
        cpuBoard = .random()
        deck = LoteriaCard.allCards.shuffled()
        calledCards = []
        currentCard = nil
        currentCardIndex = -1
        timerProgress = 0.0
        timeElapsed = 0.0
        pausedTimeRemaining = 0.0
        gameResult = nil
        gameOver = false
        isPlaying = false
    }

    /// Call this for a rematch: same settings, new boards, reshuffled deck.
    func rematch() {
        startNewGame()
    }

    // MARK: - Playback

    func play() {
        guard !isPlaying, !gameOver else { return }
        isPlaying = true

        if currentCardIndex == -1 {
            // Fresh start — call first card immediately
            callNextCard()
            pausedTimeRemaining = 0.0
        }

        // If we paused mid-countdown, fire a one-shot timer for the remaining
        // time, then switch to the normal repeating interval after that.
        if pausedTimeRemaining > 0 {
            startCardTimerWithDelay(pausedTimeRemaining)
            pausedTimeRemaining = 0.0
        } else {
            startCardTimer()
        }

        startProgressTimer()
    }

    func pause() {
        isPlaying = false
        // Snapshot how much time is left so we can resume exactly here
        pausedTimeRemaining = difficulty.interval * (1.0 - timerProgress)
        stopTimers()
    }

    // MARK: - Player Board Interaction

    /// Called when the player taps a cell on their board.
    func playerTap(cellID: UUID) {
        guard isPlaying, !gameOver else { return }
        guard let idx = playerBoard.cells.firstIndex(where: { $0.id == cellID }) else { return }
        let cell = playerBoard.cells[idx]

        // Only allow marking if this card has actually been called
        guard calledCards.contains(where: { $0.id == cell.card.id }) else { return }
        guard !cell.isMarked else { return }

        playerBoard.cells[idx].isMarked = true
        checkForWin()
    }

    // MARK: - Private: Card Calling

    private func callNextCard() {
        guard currentCardIndex < deck.count - 1 else {
            // Deck exhausted — it's a draw
            resolveGame(result: .draw)
            return
        }

        currentCardIndex += 1
        let card = deck[currentCardIndex]
        currentCard = card

        if !calledCards.contains(where: { $0.id == card.id }) {
            calledCards.append(card)
        }

        speechManager?.callCard(card.name)
        timeElapsed = 0.0
        timerProgress = 0.0
        pausedTimeRemaining = 0.0

        // CPU auto-marks after a short random delay
        scheduleCPUMark(for: card)
    }

    private func scheduleCPUMark(for card: LoteriaCard) {
        let delay = Double.random(in: difficulty.cpuMarkDelay)
        Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !gameOver else { return }
            let didMark = cpuBoard.mark(card: card)
            if didMark {
                checkForWin()
            }
        }
    }

    // MARK: - Win Detection

    private func checkForWin() {
        let playerWon = playerBoard.checkWin(conditions: winConditions)
        let cpuWon = cpuBoard.checkWin(conditions: winConditions)

        if playerWon && cpuWon {
            resolveGame(result: .draw)
        } else if playerWon {
            resolveGame(result: .playerWins)
        } else if cpuWon {
            resolveGame(result: .cpuWins)
        }
    }

    private func resolveGame(result: PlayModeResult) {
        guard !gameOver else { return }
        gameOver = true
        gameResult = result
        isPlaying = false
        stopTimers()

        switch result {
        case .playerWins: playerWins += 1
        case .cpuWins:    cpuWins += 1
        case .draw:       drawCount += 1
        }
    }

    // MARK: - Timers

    private func startCardTimer() {
        stopCardTimer()
        let t = Timer(timeInterval: difficulty.interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying, !self.gameOver else { return }
                self.callNextCard()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        cardTimer = t
    }

    /// Fires once after `delay` seconds (the paused remainder), then switches
    /// to the normal repeating full-interval timer.
    private func startCardTimerWithDelay(_ delay: TimeInterval) {
        stopCardTimer()
        let t = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying, !self.gameOver else { return }
                self.callNextCard()
                self.startCardTimer()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        cardTimer = t
    }

    private func startProgressTimer() {
        stopProgressTimer()
        // Seed timeElapsed from current timerProgress so the bar resumes
        // exactly where it was rather than jumping back to zero.
        timeElapsed = timerProgress * difficulty.interval
        let interval = 0.05
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying else { return }
                self.timeElapsed += interval
                self.timerProgress = min(self.timeElapsed / self.difficulty.interval, 1.0)
            }
        }
        RunLoop.main.add(t, forMode: .common)
        progressTimer = t
    }

    private func stopCardTimer() {
        cardTimer?.invalidate()
        cardTimer = nil
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func stopTimers() {
        stopCardTimer()
        stopProgressTimer()
    }

    // MARK: - Computed

    var progress: Double {
        guard !deck.isEmpty else { return 0 }
        return Double(currentCardIndex + 1) / Double(deck.count)
    }

    var canStart: Bool { !isPlaying && !gameOver }
}
