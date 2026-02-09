//
//  SpeechManager.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/14/26.
//

import Foundation
import AVFoundation

@MainActor
@Observable
class SpeechManager {
    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false
    var isMuted: Bool = false // Allow users to mute speech
    
    init() {
        // Configure audio session for speech
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    /// Calls out the card name in Spanish with traditional flair
    func callCard(_ name: String) {
        // Don't speak if muted
        guard !isMuted else { return }
        
        // Stop any currently speaking utterance
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create the announcement with traditional flair
        let announcement = "¡\(name)!"
        
        // Configure the utterance
        let utterance = AVSpeechUtterance(string: announcement)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = 0.4 // Slower for clear pronunciation
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for enthusiasm
        utterance.volume = 1.0 // Full volume
        
        // Speak the card name
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // Reset speaking flag after speech completes
        // Note: This is a simple approach. For production, you'd want to use AVSpeechSynthesizerDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(announcement.count) * 0.15) {
            self.isSpeaking = false
        }
    }
    
    /// Stops any current speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }
    }
    
    /// Speaks the card name with the traditional riddle (optional enhancement)
    func callCardWithRiddle(_ name: String, riddle: String) {
        // Don't speak if muted
        guard !isMuted else { return }
        
        // Stop any currently speaking utterance
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create announcement with riddle
        let announcement = "\(riddle). ¡\(name)!"
        
        // Configure the utterance
        let utterance = AVSpeechUtterance(string: announcement)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = 0.38 // Slightly slower for the riddle
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        
        // Add pauses for dramatic effect
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.3
        
        // Speak
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // Reset speaking flag
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(announcement.count) * 0.15) {
            self.isSpeaking = false
        }
    }
}
