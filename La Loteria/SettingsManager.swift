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
        // Mode Selection
        case chooseMode
        case callerMode
        case callerModeDesc
        case playMode
        case playModeDesc
        // Play Mode — Difficulty
        case chooseDifficulty
        case easy
        case easyDesc
        case medium
        case mediumDesc
        case hard
        case hardDesc
        case startGame
        // Play Mode — In Game
        case yourBoard
        case cpuBoard
        case calledCards
        case markYourCard
        case cardCalled
        case wins
        case losses
        case draws
        // Win Conditions
        case chooseWinCondition
        case winRow
        case winColumn
        case winDiagonal
        case winFullBoard
        // Result Screen
        case youWin
        case youLose
        case draw
        case playAgain
        case backToMenu
        case score
        case bingo

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
            // Mode Selection
            case .chooseMode: return "¿Cómo quieres jugar?"
            case .callerMode: return "Modo Cantor"
            case .callerModeDesc: return "Canta las cartas para que tus jugadores marquen sus tablas físicas."
            case .playMode: return "Modo Jugador"
            case .playModeDesc: return "Juega contra la computadora con tu propia tabla digital."
            // Difficulty
            case .chooseDifficulty: return "Elige la Dificultad"
            case .easy: return "Fácil"
            case .easyDesc: return "8 seg. por carta"
            case .medium: return "Normal"
            case .mediumDesc: return "5 seg. por carta"
            case .hard: return "Difícil"
            case .hardDesc: return "3 seg. por carta"
            case .startGame: return "¡Empezar!"
            // In Game
            case .yourBoard: return "Tu Tabla"
            case .cpuBoard: return "Rival"
            case .calledCards: return "Cartas Cantadas"
            case .markYourCard: return "¡Toca tus cartas para marcarlas!"
            case .cardCalled: return "Carta cantada"
            case .wins: return "Victorias"
            case .losses: return "Derrotas"
            case .draws: return "Empates"
            // Win Conditions
            case .chooseWinCondition: return "¿Cómo se gana?"
            case .winRow: return "Fila completa"
            case .winColumn: return "Columna completa"
            case .winDiagonal: return "Diagonal"
            case .winFullBoard: return "Tabla llena"
            // Result
            case .youWin: return "¡Ganaste! 🎉"
            case .youLose: return "¡Ganó la computadora! 😔"
            case .draw: return "¡Empate! 🤝"
            case .playAgain: return "¡Revancha!"
            case .backToMenu: return "Menú Principal"
            case .score: return "Marcador"
            case .bingo: return "¡LOTERÍA!"
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
            // Mode Selection
            case .chooseMode: return "How do you want to play?"
            case .callerMode: return "Caller Mode"
            case .callerModeDesc: return "Call cards while players mark their own physical boards."
            case .playMode: return "Player Mode"
            case .playModeDesc: return "Play against the computer with your own digital board."
            // Difficulty
            case .chooseDifficulty: return "Choose Difficulty"
            case .easy: return "Easy"
            case .easyDesc: return "8 sec. per card"
            case .medium: return "Normal"
            case .mediumDesc: return "5 sec. per card"
            case .hard: return "Hard"
            case .hardDesc: return "3 sec. per card"
            case .startGame: return "Let's Play!"
            // In Game
            case .yourBoard: return "Your Board"
            case .cpuBoard: return "Rival"
            case .calledCards: return "Called Cards"
            case .markYourCard: return "Tap your cards to mark them!"
            case .cardCalled: return "Card called"
            case .wins: return "Wins"
            case .losses: return "Losses"
            case .draws: return "Draws"
            // Win Conditions
            case .chooseWinCondition: return "Win Condition"
            case .winRow: return "Complete row"
            case .winColumn: return "Complete column"
            case .winDiagonal: return "Diagonal"
            case .winFullBoard: return "Full board"
            // Result
            case .youWin: return "You Win! 🎉"
            case .youLose: return "Computer Wins! 😔"
            case .draw: return "It's a Draw! 🤝"
            case .playAgain: return "Rematch!"
            case .backToMenu: return "Main Menu"
            case .score: return "Score"
            case .bingo: return "LOTERÍA!"
            }
        }
    }
}
