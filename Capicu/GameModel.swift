import SwiftUI
import Observation

struct ScoreEntry: Identifiable {
    let id = UUID()
    let nosotros: Int
    let ellos: Int
    let team: String
    let points: Int
}

struct GameResult: Identifiable {
    let id = UUID()
    let gameNumber: Int
    let nosotros: Int
    let ellos: Int
    let winner: String
    let history: [ScoreEntry]
}

@Observable
class GameModel {
    static let winningScore = 200

    var nosotros = 0
    var ellos = 0
    var nosotrosInput = ""
    var ellosInput = ""
    var history: [ScoreEntry] = []
    var gameLog: [GameResult] = []
    var winner: String? = nil
    var gameActive = false

    var hasActiveGame: Bool {
        nosotros > 0 || ellos > 0 || !history.isEmpty
    }

    var nosotrosPct: Double {
        min(Double(nosotros) / Double(Self.winningScore), 1.0)
    }

    var ellosPct: Double {
        min(Double(ellos) / Double(Self.winningScore), 1.0)
    }

    var nosotrosRemaining: Int {
        max(Self.winningScore - nosotros, 0)
    }

    var ellosRemaining: Int {
        max(Self.winningScore - ellos, 0)
    }

    var gameOver: Bool {
        winner != nil
    }

    func addPoints(team: String) {
        guard winner == nil else { return }

        let input = team == "nosotros" ? nosotrosInput : ellosInput
        guard let pts = Int(input), pts > 0 else { return }

        if team == "nosotros" {
            nosotros += pts
            nosotrosInput = ""
        } else {
            ellos += pts
            ellosInput = ""
        }

        history.append(ScoreEntry(
            nosotros: nosotros,
            ellos: ellos,
            team: team,
            points: pts
        ))

        if nosotros >= Self.winningScore {
            winner = "nosotros"
        } else if ellos >= Self.winningScore {
            winner = "ellos"
        }
    }

    func undo() {
        guard !history.isEmpty else { return }
        history.removeLast()

        if let last = history.last {
            nosotros = last.nosotros
            ellos = last.ellos
        } else {
            nosotros = 0
            ellos = 0
        }
        winner = nil
    }

    func newGame() {
        if nosotros > 0 || ellos > 0 {
            gameLog.append(GameResult(
                gameNumber: gameLog.count + 1,
                nosotros: nosotros,
                ellos: ellos,
                winner: winner ?? (nosotros > ellos ? "nosotros" : ellos > nosotros ? "ellos" : "empate"),
                history: history
            ))
        }

        nosotros = 0
        ellos = 0
        nosotrosInput = ""
        ellosInput = ""
        history = []
        winner = nil
    }

    func startNewGame() {
        if hasActiveGame {
            newGame()
        }
        gameActive = true
    }

    func returnToMenu() {
        if hasActiveGame && winner == nil {
            newGame()
        }
        gameActive = false
    }

    var nosotrosWins: Int {
        gameLog.filter { $0.winner == "nosotros" }.count
    }

    var ellosWins: Int {
        gameLog.filter { $0.winner == "ellos" }.count
    }
}
