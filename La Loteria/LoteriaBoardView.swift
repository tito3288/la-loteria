//
//  LoteriaBoardView.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import SwiftUI

struct LoteriaBoardView: View {
    let board: LoteriaBoardModel
    let title: String
    let isInteractive: Bool
    let calledCardIDs: Set<Int>           // IDs of cards that have been called
    let onTap: ((UUID) -> Void)?          // Only used when isInteractive = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(board.markedCount)/16")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .monospacedDigit()
            }

            // 4x4 Grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(board.cells) { cell in
                    BoardCellView(
                        cell: cell,
                        isCalled: calledCardIDs.contains(cell.card.id),
                        isInteractive: isInteractive
                    )
                    .onTapGesture {
                        if isInteractive {
                            onTap?(cell.id)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.15))
        )
    }
}

// MARK: - Individual Cell

private struct BoardCellView: View {
    let cell: BoardCell
    let isCalled: Bool      // Has this card appeared in the draw pile?
    let isInteractive: Bool

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .aspectRatio(0.72, contentMode: .fit) // Card-like ratio

            // Card image
            Image(cell.card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .opacity(cell.isMarked ? 0.35 : (isCalled && isInteractive ? 1.0 : 0.85))

            // Marked overlay
            if cell.isMarked {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.55))

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: cell.isMarked)
    }

    private var backgroundColor: Color {
        if cell.isMarked {
            return .green.opacity(0.3)
        } else if isCalled && isInteractive {
            return .white.opacity(0.25)
        } else {
            return .white.opacity(0.1)
        }
    }
}
