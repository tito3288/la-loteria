//
//  ContentView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var gameManager = LoteriaGameManager()
    let settings: SettingsManager
    let speechManager: SpeechManager
    let onExit: (() -> Void)?          // Back to mode selection
    @State private var showHistory = false
    @State private var showSettings = false

    init(
        settings: SettingsManager,
        speechManager: SpeechManager,
        onExit: (() -> Void)? = nil
    ) {
        self.settings = settings
        self.speechManager = speechManager
        self.onExit = onExit
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.9),
                    Color(red: 0.1, green: 0.6, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overall Progress Bar (above card)
                        overallProgressView
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Main Card Display
                        mainCardView
                            .padding(.horizontal, 20)
                        
                        // Controls Section
                        controlsView
                            .padding(.horizontal, 20)
                        
                        // Speed Selection
                        speedSelectionView
                            .padding(.horizontal, 20)
                        
                        // Card History
                        cardHistoryView
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            HistorySheetView(gameManager: gameManager, settings: settings, isPresented: $showHistory)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings, speechManager: speechManager, isPresented: $showSettings)
        }
        .onAppear {
            // Connect speech manager to game manager
            gameManager.speechManager = speechManager
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // Back to mode selection
            if let onExit {
                Button(action: onExit) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }

            Text(settings.localize(.loteria))
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )
            }
            
            Button {
                showHistory = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(settings.localize(.history))
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.2))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Overall Progress View
    
    private var overallProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text(gameManager.currentCard == nil ? settings.localize(.ready) : settings.localize(.playing))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(gameManager.currentCardIndex + 1) / 54")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            ProgressView(value: gameManager.progress)
                .tint(.white)
                .background(.white.opacity(0.3))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Main Card View
    
    private var mainCardView: some View {
        VStack(spacing: 0) {
            // Card Number Badge
            HStack {
                if let card = gameManager.currentCard {
                    Text("#\(card.id)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.3))
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Card Display Area
            VStack(spacing: 12) {
                if let card = gameManager.currentCard {
                    // Card Image (Real)
                    Image(card.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    
                    Text(card.name)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(card.riddle)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                } else {
                    // Welcome Icon and Text
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.8))
                            .symbolEffect(.pulse)
                        
                        Text(settings.localize(.pressPlayToStart))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.15))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
    
    // MARK: - Controls View
    
    private var controlsView: some View {
        VStack(spacing: 16) {
            // Timer Progress Bar (Countdown to next card) - Always reserve space
            VStack(spacing: 8) {
                HStack {
                    Text(settings.localize(.nextCardIn))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(String(format: "%.1fs", gameManager.gameSpeed.interval * (1.0 - gameManager.timerProgress)))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .monospacedDigit()
                }
                .opacity(gameManager.currentCard == nil ? 0.0 : 1.0)
                
                ProgressView(value: gameManager.timerProgress)
                    .tint(.green.opacity(0.8))
                    .background(.white.opacity(0.3))
                    .clipShape(Capsule())
            }
            .frame(height: 32) // Fixed height to prevent layout shifts
            
            // Play/Pause Button (Full Width)
            Button {
                if gameManager.isPlaying {
                    gameManager.pause()
                } else {
                    gameManager.play()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: gameManager.isPlaying ? "pause.fill" : "play.fill")
                    Text(gameManager.isPlaying ? settings.localize(.pause) : settings.localize(.play))
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.35))
                )
            }
            
            HStack(spacing: 12) {
                // Reshuffle Button
                Button {
                    withAnimation {
                        gameManager.reshuffle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                        Text(settings.localize(.reshuffle))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.25))
                    )
                }
                
                // Next Button
                Button {
                    gameManager.next()
                } label: {
                    HStack(spacing: 6) {
                        Text(settings.localize(.next))
                        Image(systemName: "forward.fill")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(gameManager.canGoNext ? 0.25 : 0.1))
                    )
                }
                .disabled(!gameManager.canGoNext)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.15))
        )
    }
    
    // MARK: - Speed Selection View
    
    private var speedSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(settings.localize(.speed))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                ForEach(LoteriaGameManager.GameSpeed.allCases, id: \.self) { speed in
                    Button {
                        gameManager.setSpeed(speed)
                    } label: {
                        let localizedSpeed: String = {
                            switch speed {
                            case .slow: return settings.localize(.slow)
                            case .normal: return settings.localize(.normal)
                            case .fast: return settings.localize(.fast)
                            }
                        }()
                        
                        Text(localizedSpeed)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(gameManager.gameSpeed == speed ? 0.4 : 0.2))
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.15))
        )
    }
    
    // MARK: - Card History View
    
    private var cardHistoryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(settings.localize(.cardHistory))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            
            if gameManager.calledCards.isEmpty {
                Text(settings.localize(.noCardsYet))
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(gameManager.calledCards.reversed()) { card in
                            VStack(spacing: 8) {
                                // Card image in history
                                Image(card.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 100)
                                    .overlay(
                                        Rectangle()
                                            .stroke(.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Text(card.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Text(settings.localize(.tipClickHistory))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - History Sheet View

struct HistorySheetView: View {
    let gameManager: LoteriaGameManager
    let settings: SettingsManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.4, blue: 0.9),
                        Color(red: 0.1, green: 0.6, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if gameManager.calledCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Text(settings.localize(.noHistoryYet))
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        
                        Text(settings.localize(.startPlayingToSee))
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(gameManager.calledCards) { card in
                                VStack(spacing: 8) {
                                    // Card image
                                    Image(card.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 140)
                                        .overlay(
                                            Rectangle()
                                                .stroke(.white.opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    VStack(spacing: 2) {
                                        Text("#\(card.id)")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white.opacity(0.7))
                                        
                                        Text(card.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white.opacity(0.1))
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(settings.localize(.cardHistory))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.localize(.done)) {
                        isPresented = false
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.2, green: 0.4, blue: 0.9), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    let settings: SettingsManager
    let speechManager: SpeechManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.4, blue: 0.9),
                        Color(red: 0.1, green: 0.6, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Language Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text(settings.localize(.selectLanguage))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            
                            ForEach(SettingsManager.Language.allCases, id: \.self) { language in
                                Button {
                                    withAnimation {
                                        settings.selectedLanguage = language
                                    }
                                } label: {
                                    HStack {
                                        Text(language.flag)
                                            .font(.system(size: 32))
                                        
                                        Text(language.rawValue)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        if settings.selectedLanguage == language {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(.green)
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.white.opacity(settings.selectedLanguage == language ? 0.3 : 0.15))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Voice Announcements Toggle
                        VStack(alignment: .leading, spacing: 16) {
                            Text(settings.localize(.voiceAnnouncements))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Toggle(isOn: Binding(
                                get: { !speechManager.isMuted },
                                set: { speechManager.isMuted = !$0 }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: speechManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                    
                                    Text(settings.localize(.enableVoice))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                            }
                            .tint(.green)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.2))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle(settings.localize(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.localize(.done)) {
                        isPresented = false
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.2, green: 0.4, blue: 0.9), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    @Previewable @State var settings = SettingsManager()
    @Previewable @State var speechManager = SpeechManager()
    ContentView(settings: settings, speechManager: speechManager)
}
