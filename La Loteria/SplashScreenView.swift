//
//  SplashScreenView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/15/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0

    @State private var cardScale: CGFloat = 0.6
    @State private var cardOpacity: CGFloat = 0.0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: CGFloat = 0.0
    @State private var buenasOffset: CGFloat = 40
    @State private var buenasOpacity: CGFloat = 0.0
    @State private var subtitleOpacity: CGFloat = 0.0

    var body: some View {
        if isActive {
            ModeSelectionView()
        } else {
            ZStack {
                // Blue gradient — matches the rest of the app
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
                    Spacer()

                    // ¡BUENAS! banner
                    Text("BUENAS!")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.2),
                                    Color(red: 1.0, green: 0.65, blue: 0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                        .offset(y: buenasOffset)
                        .opacity(buenasOpacity)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(.white.opacity(0.35))
                            .frame(height: 1.5)
                        Text("✦")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(.white.opacity(0.35))
                            .frame(height: 1.5)
                    }
                    .padding(.horizontal, 48)
                    .padding(.top, 14)
                    .opacity(buenasOpacity)

                    // Center card — La Chalupa (card_48)
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.75, blue: 0.1).opacity(0.4),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 60,
                                    endRadius: 130
                                )
                            )
                            .frame(width: 260, height: 260)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .frame(width: 170, height: 230)
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)

                        Image("card_48")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 166, height: 226)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .padding(.top, 18)
                    .padding(.bottom, 22)

                    // Title
                    VStack(spacing: 4) {
                        Text("La Lotería")
                            .font(.system(size: 38, weight: .black, design: .serif))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                        Text("El juego de mesa que empieza peleas familiares")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                            .tracking(1.2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                    Spacer()

                    Text("Listo para jugar!")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.bottom, 40)
                        .opacity(subtitleOpacity)
                }
            }
            .opacity(opacity)
            .onAppear { runEntranceAnimation() }
        }
    }

    private func runEntranceAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.2)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            buenasOffset = 0
            buenasOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
            titleOffset = 0
            titleOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.85)) {
            subtitleOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
