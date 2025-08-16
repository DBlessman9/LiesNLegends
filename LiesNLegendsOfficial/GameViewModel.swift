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
    @Published var playerSelections: [Player: Player?] = [:] // For legitimate players guessing imposter
    @Published var imposterAnswers: [Player: String] = [:] // For imposters guessing correct answer
    @Published var showResults: Bool = false
    @Published var disqualifiedPlayer: Player? = nil
    @Published var scoresCalculated = false

    // MARK: - Game Logic
    func addPlayer(name: String) {
        // Check if a player with this name already exists
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        // Check for duplicate names (case-insensitive)
        let isDuplicate = players.contains { $0.name.lowercased() == trimmedName.lowercased() }
        
        if isDuplicate {
            print("⚠️ Cannot add player: '\(trimmedName)' - name already exists")
            return
        }
        
        let newPlayer = Player(name: trimmedName, status: "alive", score: 0)
        players.append(newPlayer)
        print("✅ Added player: '\(trimmedName)' - Total players: \(players.count)")
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }

    func clearPlayers() {
        print("🧹 Clearing all players and game data...")
        
        // Clear all player-related data safely
        players.removeAll()
        playerSelections.removeAll()
        imposterAnswers.removeAll()
        winners.removeAll()
        
        // Ensure all references are properly cleared
        imposter = nil
        legitimates.removeAll()
        
        print("🧹 All players cleared. Current player count: \(players.count)")
        
        // Force UI update
        objectWillChange.send()
    }
    

    
    func canStartGame() -> Bool {
        // Check if we have enough players
        guard players.count >= 4 else { 
            print("❌ Not enough players: \(players.count)/4")
            return false 
        }
        
        // Check for duplicate names
        let playerNames = players.map { $0.name }
        let uniqueNames = Set(playerNames)
        
        if playerNames.count != uniqueNames.count {
            print("❌ Duplicate player names detected: \(playerNames)")
            print("❌ Unique names: \(Array(uniqueNames))")
            return false
        }
        
        print("✅ Game can start: \(players.count) unique players")
        return true
    }
    

    
    func clearSelections() {
        playerSelections.removeAll()
        imposterAnswers.removeAll()
    }
    
    func disqualifyPlayer(_ player: Player) {
        print("🚫 Disqualifying player: \(player.name)")
        print("🚫 Current player scores before disqualification:")
        for p in players {
            print("🚫 \(p.name): \(p.score) points (isImposter: \(p.isImposter))")
        }
        
        // Set the disqualified player
        disqualifiedPlayer = player
        
        // Award 1 point to all OTHER players (excluding only the disqualified player)
        for i in 0..<players.count {
            if players[i].id != player.id {
                let oldScore = players[i].score
                players[i].score += 1
                print("✅ Awarded 1 point to \(players[i].name) for disqualification of \(player.name)")
                print("✅ \(players[i].name) score changed from \(oldScore) to \(players[i].score)")
            } else {
                print("🚫 Skipped \(players[i].name) - they are the disqualified player")
            }
        }
        
        // Set all other players (excluding disqualified player) as winners
        winners = players.filter { $0.id != player.id }
        
        // Set game state to game over
        gameState = .gameOver
        
        print("🏆 Winners after disqualification: \(winners.map { $0.name })")
        print("🚫 Final player scores after disqualification:")
        for p in players {
            print("🚫 \(p.name): \(p.score) points (isImposter: \(p.isImposter))")
        }
    }

    func pickCategory(_ category: String, word: String) {
        currentCategory = category
        currentWord = word
    }

    func assignRoles() {
        // Check for duplicate names first
        let playerNames = players.map { $0.name }
        let uniqueNames = Set(playerNames)
        
        if playerNames.count != uniqueNames.count {
            print("❌ ERROR: Duplicate player names detected! Cannot assign roles.")
            print("❌ Player names: \(playerNames)")
            print("❌ Unique names: \(Array(uniqueNames))")
            return
        }
        
        guard players.count > 1 else {
            print("Not enough players to assign roles! Current players: \(players.map { $0.name })")
            return
        }
        
        print("🔄 Starting role assignment...")
        print("🔄 Players before assignment: \(players.map { "\($0.name)(\($0.isImposter ? "I" : "L"))" })")
        
        // Reset all players to legitimate first
        for player in players {
            player.isImposter = false
            player.isLegitimate = true
        }
        
        print("🔄 Players after reset: \(players.map { "\($0.name)(\($0.isImposter ? "I" : "L"))" })")
        
        // Pick a random player to be the imposter
        let randomIndex = Int.random(in: 0..<players.count)
        players[randomIndex].isImposter = true
        players[randomIndex].isLegitimate = false
        
        print("🔄 Random index selected: \(randomIndex)")
        print("🔄 Player at index \(randomIndex): \(players[randomIndex].name)")
        
        // Update the imposter and legitimates references
        imposter = players[randomIndex]
        legitimates = players.filter { !$0.isImposter }
        
        print("🔄 Final roles assigned:")
        print("🔄 Imposter: \(imposter?.name ?? "None")")
        print("🔄 Legitimates: \(legitimates.map { $0.name })")
        print("🔄 Final player states: \(players.map { "\($0.name)(\($0.isImposter ? "I" : "L"))" })")
    }

    func startNewRound() {
        // Don't increment round here - it should only be incremented when continuing to next round
        // Don't reassign roles - they were already assigned when category was picked
        // assignRoles() // REMOVED - this was causing roles to change during the game!
        playerSelections = [:]
        imposterAnswers = [:]
        showResults = false
        gameState = .playing
    }
    
    func resetCardFlipState() {
        // This will be used to reset the card flip state when starting a new round
        // The CardFlipView will handle this internally
    }
    
    func continueToNextRound() {
        // Increment round number when continuing to next round
        // This happens when a round is completed and we're moving to the next one
        currentRound += 1
        print("🔄 Round \(currentRound - 1) completed, moving to Round \(currentRound)")
        
        // Save current players and scores for next round
        // Don't clear players, just reset game state
        // Clear all selections and answers for new round
        playerSelections.removeAll()
        imposterAnswers.removeAll()
        // Clear disqualification state for new round
        disqualifiedPlayer = nil
        // Reset score calculation flag for new round
        scoresCalculated = false
        // Reset game state
        showResults = false
        gameState = .playing
        // Keep existing players and accumulated scores
        // assignRoles() will be called when the category is selected for the new round
        print("🔄 Continuing to next round - round \(currentRound) ready for category selection")
    }
    
    func continueAfterDisqualification() {
        // Special function for continuing after disqualification
        // Don't increment round - this was a disqualification, not a completed round
        // Clear all selections and answers for new round
        playerSelections.removeAll()
        imposterAnswers.removeAll()
        // Clear disqualification state for new round
        disqualifiedPlayer = nil
        // Reset game state
        showResults = false
        gameState = .playing
        // Keep existing players and accumulated scores
        // assignRoles() will be called when the category is selected for the new round
        print("🔄 Continuing after disqualification - round not incremented")
    }
    
    func initializeFirstRound() {
        // For the very first round, just set up the initial state
        // Don't clear anything yet
        gameState = .playing
    }
    
    func resetForNewGame() {
        print("🔄 Starting new game reset...")
        
        // Clear all game state first (before clearing players)
        playerSelections.removeAll()
        imposterAnswers.removeAll()
        winners.removeAll()
        disqualifiedPlayer = nil
        
        // Reset game state variables
        currentRound = 1
        currentCategory = ""
        currentWord = ""
        gameState = .setup
        showResults = false
        
        // Clear player references safely
        imposter = nil
        legitimates.removeAll()
        
        // Clear all players last
        players.removeAll()
        
        print("🔄 New game reset complete. Players: \(players.count), Game state: \(gameState)")
        
        // Force UI update
        objectWillChange.send()
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