//
//  SettingsManager.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/14/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class SettingsManager {
    var selectedLanguage: Language = .spanish
    
    enum Language: String, CaseIterable {
        case spanish = "Español"
        case english = "English"
        
        var code: String {
            switch self {
            case .spanish: return "es"
            case .english: return "en"
            }
        }
        
        var flag: String {
            switch self {
            case .spanish: return "🇲🇽"
            case .english: return "🇺🇸"
            }
        }
    }
    
    // Localized strings
    func localize(_ key: LocalizationKey) -> String {
        switch selectedLanguage {
        case .spanish:
            return key.spanish
        case .english:
            return key.english
        }
    }
    
    enum LocalizationKey {
        case loteria
        case history
        case playing
        case ready
        case nextCardIn
        case play
        case pause
        case reshuffle
        case next
        case speed
        case slow
        case normal
        case fast
        case cardHistory
        case noCardsYet
        case pressPlayToStart
        case tipClickHistory
        case noHistoryYet
        case startPlayingToSee
        case readyToCall
        case settings
        case language
        case done
        case selectLanguage
        case voiceAnnouncements
        case enableVoice
        
        var spanish: String {
            switch self {
            case .loteria: return "Lotería"
            case .history: return "Historial"
            case .playing: return "Jugando"
            case .ready: return "Listo"
            case .nextCardIn: return "Próxima carta en"
            case .play: return "Jugar"
            case .pause: return "Pausar"
            case .reshuffle: return "Barajar"
            case .next: return "Siguiente"
            case .speed: return "Velocidad"
            case .slow: return "Lento"
            case .normal: return "Normal"
            case .fast: return "Rápido"
            case .cardHistory: return "Historial de Cartas"
            case .noCardsYet: return "¡Aún no hay cartas! ¡Presiona Jugar para comenzar!"
            case .pressPlayToStart: return "Presiona Jugar para Comenzar"
            case .tipClickHistory: return "Consejo: Haz clic en una carta del historial para volver a ella."
            case .noHistoryYet: return "Sin Historial Aún"
            case .startPlayingToSee: return "¡Comienza a jugar para ver tus cartas aquí!"
            case .readyToCall: return "Listo para llamar"
            case .settings: return "Ajustes"
            case .language: return "Idioma"
            case .done: return "Listo"
            case .selectLanguage: return "Seleccionar Idioma"
            case .voiceAnnouncements: return "Anuncios de Voz"
            case .enableVoice: return "Habilitar llamadas de voz"
            }
        }
        
        var english: String {
            switch self {
            case .loteria: return "Lotería"
            case .history: return "History"
            case .playing: return "Playing"
            case .ready: return "Ready"
            case .nextCardIn: return "Next card in"
            case .play: return "Play"
            case .pause: return "Pause"
            case .reshuffle: return "Reshuffle"
            case .next: return "Next"
            case .speed: return "Speed"
            case .slow: return "Slow"
            case .normal: return "Normal"
            case .fast: return "Fast"
            case .cardHistory: return "Card History"
            case .noCardsYet: return "No cards called yet. Press Play to start!"
            case .pressPlayToStart: return "Press Play to Start"
            case .tipClickHistory: return "Tip: Click a history card to jump back to it."
            case .noHistoryYet: return "No History Yet"
            case .startPlayingToSee: return "Start playing to see your called cards here!"
            case .readyToCall: return "Ready to call"
            case .settings: return "Settings"
            case .language: return "Language"
            case .done: return "Done"
            case .selectLanguage: return "Select Language"
            case .voiceAnnouncements: return "Voice Announcements"
            case .enableVoice: return "Enable voice calling"
            }
        }
    }
}
