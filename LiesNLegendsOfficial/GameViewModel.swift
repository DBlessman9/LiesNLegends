import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var players: [Player] = []
    @Published var currentRound: Int = 1
    @Published var currentCategory: String = ""
    @Published var currentWord: String = ""
    @Published var imposter: Player?
    @Published var legitimates: [Player] = []
    @Published var gameState: GameState = .setup
    @Published var doesHighestScoreWin: Bool = true
    @Published var winners: [Player] = []
    @Published var playerSelections: [Player: Player?] = [:]
    @Published var showResults: Bool = false

    // MARK: - Game Logic
    func addPlayer(name: String) {
        let newPlayer = Player(name: name, status: "alive", score: 0)
        players.append(newPlayer)
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }

    func clearPlayers() {
        players.removeAll()
    }

    func pickCategory(_ category: String, word: String) {
        currentCategory = category
        currentWord = word
    }

    func assignRoles() {
        guard players.count > 1 else {
            print("Not enough players to assign roles! Current players: \(players.map { $0.name })")
            return
        }
        let tempPlayers = players.map { player in
            var updated = player
            updated.isImposter = false
            updated.isLegitimate = true
            return updated
        }
        let randomIndex = Int.random(in: 0..<tempPlayers.count)
        tempPlayers[randomIndex].isImposter = true
        tempPlayers[randomIndex].isLegitimate = false
        imposter = tempPlayers[randomIndex]
        legitimates = tempPlayers.filter { !$0.isImposter }
        players = tempPlayers
        print("Roles assigned. Imposter: \(imposter?.name ?? "None"). Legitimates: \(legitimates.map { $0.name })")
    }

    func startNewRound() {
        currentRound += 1
        assignRoles()
        playerSelections = [:]
        showResults = false
        gameState = .playing
    }

    func recordSelection(for player: Player, guessedImposter: Player?) {
        playerSelections[player] = guessedImposter
    }

    func calculateWinners() {
        // Example: Legitimates get a point for correct guess
        for (player, guess) in playerSelections {
            if let guess = guess, guess.id == imposter?.id, !player.isImposter {
                if let idx = players.firstIndex(where: { $0.id == player.id }) {
                    players[idx].score += 1
                }
            }
        }
        // Determine winners
        let maxScore = players.map { $0.score }.max() ?? 0
        winners = players.filter { $0.score == maxScore }
        gameState = .gameOver
    }

    func resetScores(to newValue: Int = 0) {
        for idx in players.indices {
            players[idx].score = newValue
        }
    }
} 