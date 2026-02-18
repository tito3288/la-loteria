//
//  LoteriaBoardModel.swift
//  La Loteria
//
//  Created by Bryan Arambula on 2/18/26.
//

import Foundation

// MARK: - Win Condition

enum WinCondition: String, CaseIterable, Identifiable {
    case row        = "row"
    case column     = "column"
    case diagonal   = "diagonal"
    case fullBoard  = "fullBoard"

    var id: String { rawValue }
}

// MARK: - Board Cell

struct BoardCell: Identifiable {
    let id: UUID = UUID()
    let card: LoteriaCard
    var isMarked: Bool = false
}

// MARK: - Board Model

struct LoteriaBoardModel {
    /// 4×4 grid stored row-major: index = row * 4 + col
    var cells: [BoardCell]

    /// Generate a random board by picking 16 unique cards from the full deck.
    static func random() -> LoteriaBoardModel {
        let picked = Array(LoteriaCard.allCards.shuffled().prefix(16))
        let cells = picked.map { BoardCell(card: $0) }
        return LoteriaBoardModel(cells: cells)
    }

    // MARK: - Marking

    /// Mark the cell matching this card, if it exists on the board. Returns true if something was newly marked.
    @discardableResult
    mutating func mark(card: LoteriaCard) -> Bool {
        guard let idx = cells.firstIndex(where: { $0.card.id == card.id && !$0.isMarked }) else {
            return false
        }
        cells[idx].isMarked = true
        return true
    }

    // MARK: - Win Detection

    /// Returns true if the board satisfies ANY of the supplied win conditions.
    func checkWin(conditions: Set<WinCondition>) -> Bool {
        for condition in conditions {
            switch condition {
            case .row:
                if hasCompleteRow() { return true }
            case .column:
                if hasCompleteColumn() { return true }
            case .diagonal:
                if hasCompleteDiagonal() { return true }
            case .fullBoard:
                if isFullyMarked() { return true }
            }
        }
        return false
    }

    private func isMarked(row: Int, col: Int) -> Bool {
        cells[row * 4 + col].isMarked
    }

    private func hasCompleteRow() -> Bool {
        for row in 0..<4 {
            if (0..<4).allSatisfy({ isMarked(row: row, col: $0) }) { return true }
        }
        return false
    }

    private func hasCompleteColumn() -> Bool {
        for col in 0..<4 {
            if (0..<4).allSatisfy({ isMarked(row: $0, col: col) }) { return true }
        }
        return false
    }

    private func hasCompleteDiagonal() -> Bool {
        let mainDiag = (0..<4).allSatisfy { isMarked(row: $0, col: $0) }
        let antiDiag = (0..<4).allSatisfy { isMarked(row: $0, col: 3 - $0) }
        return mainDiag || antiDiag
    }

    private func isFullyMarked() -> Bool {
        cells.allSatisfy(\.isMarked)
    }

    // MARK: - Stats

    var markedCount: Int { cells.filter(\.isMarked).count }
}
