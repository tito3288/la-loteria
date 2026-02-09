//
//  LoteriaGameManager.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/14/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class LoteriaGameManager {
    // Game State
    var deck: [LoteriaCard] = []
    var calledCards: [LoteriaCard] = []
    var currentCard: LoteriaCard?
    var currentCardIndex: Int = -1
    
    // Playback State
    var isPlaying: Bool = false
    var gameSpeed: GameSpeed = .normal
    
    // Timer Progress
    var timerProgress: Double = 0.0
    private var timeElapsed: TimeInterval = 0.0
    private var pausedTimeRemaining: TimeInterval = 0.0
    
    // Timer
    private var timer: Timer?
    private var progressTimer: Timer?
    
    // Speech Manager
    var speechManager: SpeechManager?
    
    enum GameSpeed: String, CaseIterable {
        case slow = "Slow"
        case normal = "Normal"
        case fast = "Fast"
        
        var interval: TimeInterval {
            switch self {
            case .slow: return 8.0
            case .normal: return 5.0
            case .fast: return 3.0
            }
        }
    }
    
    init() {
        reshuffle()
    }
    
    // MARK: - Game Controls
    
    func reshuffle() {
        stopPlaying()
        speechManager?.stopSpeaking()
        deck = LoteriaCard.allCards.shuffled()
        calledCards = []
        currentCard = nil
        currentCardIndex = -1
        pausedTimeRemaining = 0.0
    }
    
    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        
        // If we're at the end or haven't started, start from beginning
        if currentCardIndex >= deck.count - 1 {
            currentCardIndex = -1
            calledCards = []
            pausedTimeRemaining = 0.0
        }
        
        // Call first card immediately if we haven't started
        if currentCardIndex == -1 {
            callNextCard()
            startProgressTimer()
        } else {
            // Resume with progress timer if we already have a card
            startProgressTimer()
        }
        
        // Start the main timer with remaining time if we paused mid-countdown
        if pausedTimeRemaining > 0 {
            startTimerWithDelay(pausedTimeRemaining)
            pausedTimeRemaining = 0.0
        } else {
            startTimer()
        }
    }
    
    func pause() {
        isPlaying = false
        // Calculate remaining time before stopping timers
        pausedTimeRemaining = gameSpeed.interval * (1.0 - timerProgress)
        stopTimer()
        stopProgressTimer()
    }
    
    func stopPlaying() {
        isPlaying = false
        stopTimer()
        stopProgressTimer()
        resetTimerProgress()
        pausedTimeRemaining = 0.0
    }
    
    func next() {
        // Stop both timers before advancing so they don't stack
        stopTimer()
        stopProgressTimer()
        callNextCard()
        pausedTimeRemaining = 0.0
        // Restart timers fresh if the game is still playing
        if isPlaying {
            startTimer()
            startProgressTimer()
        }
    }
    
    func previous() {
        guard currentCardIndex > 0 else { return }
        currentCardIndex -= 1
        currentCard = deck[currentCardIndex]
    }
    
    func jumpToCard(_ card: LoteriaCard) {
        guard let index = calledCards.firstIndex(of: card) else { return }
        currentCardIndex = index
        currentCard = deck[currentCardIndex]
        
        // Announce the card when jumping back to it
        speechManager?.callCard(card.name)
    }
    
    func setSpeed(_ speed: GameSpeed) {
        gameSpeed = speed
        // Always reset progress when speed changes, whether playing or paused
        stopTimer()
        stopProgressTimer()
        timeElapsed = 0.0
        timerProgress = 0.0
        pausedTimeRemaining = 0.0
        // Only restart timers if the game is actively playing
        if isPlaying {
            startTimer()
            startProgressTimer()
        }
    }
    
    // MARK: - Private Methods
    
    private func callNextCard() {
        guard currentCardIndex < deck.count - 1 else {
            // Reached the end
            stopPlaying()
            return
        }
        
        currentCardIndex += 1
        currentCard = deck[currentCardIndex]
        
        if !calledCards.contains(deck[currentCardIndex]) {
            calledCards.append(deck[currentCardIndex])
        }
        
        // Announce the card in Spanish!
        if let card = currentCard {
            speechManager?.callCard(card.name)
        }
        
        // Reset timer progress values (caller is responsible for managing timers)
        timeElapsed = 0.0
        timerProgress = 0.0
    }
    
    private func startTimer() {
        let t = Timer(timeInterval: gameSpeed.interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.callNextCard()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    
    private func startTimerWithDelay(_ delay: TimeInterval) {
        let t = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.callNextCard()
                self?.startTimer()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startProgressTimer() {
        let updateInterval = 0.05 // Update 20 times per second for smooth animation
        let t = Timer(timeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.timeElapsed += updateInterval
                self.timerProgress = min(self.timeElapsed / self.gameSpeed.interval, 1.0)
            }
        }
        RunLoop.main.add(t, forMode: .common)
        progressTimer = t
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func resetTimerProgress() {
        stopProgressTimer() // Always stop before restarting to prevent stacking
        timeElapsed = 0.0
        timerProgress = 0.0
        if isPlaying {
            startProgressTimer()
        }
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard !deck.isEmpty else { return 0 }
        return Double(currentCardIndex + 1) / Double(deck.count)
    }
    
    var progressText: String {
        guard !deck.isEmpty else { return "0/54" }
        return "\(currentCardIndex + 1)/\(deck.count)"
    }
    
    var cardsRemaining: Int {
        max(0, deck.count - (currentCardIndex + 1))
    }
    
    var canGoNext: Bool {
        currentCardIndex < deck.count - 1
    }
    
    var canGoPrevious: Bool {
        currentCardIndex > 0
    }
}
