//
//  RevealImposter.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation

struct RevealImposterView: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea(edges: .all)
            
            VStack {
                // Top bar with speaker button
                HStack {
                    Spacer()
                    SpeakerButton()
                        .environmentObject(soundManager)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
                
                Image("LogoDark")
                    .resizable()
                    .frame(width: 296, height: 80)
                    .padding()
                
                // Show round information
                Text("Round \(gameVM.currentRound)")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .bold()
                    .padding(.bottom, 10)
                
                Text("The Imposter was:")
                    .font(.title)
                    .padding()
                
                Text(gameVM.imposter?.name ?? "Unknown")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                
                                // Check if there's a disqualified player
                Group {
                    if let disqualifiedPlayer = gameVM.disqualifiedPlayer {
                        disqualificationView(disqualifiedPlayer: disqualifiedPlayer)
                    } else {
                        normalGameResultsView()
                    }
                }
                .frame(maxHeight: 300)
                
                Spacer()
                
                // Button to go to ScoreBoard
                NavigationLink(destination: ScoreBoard(path: $path).environmentObject(gameVM)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("SEE SCORES")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .onAppear {
                    print("🎯 REVEAL IMPOSTER VIEW APPEARED")
                    print("🎯 Game state: \(gameVM.gameState)")
                    print("🎯 Current round: \(gameVM.currentRound)")
                    print("🎯 Disqualified player: \(gameVM.disqualifiedPlayer?.name ?? "none")")
                    print("🎯 Scores calculated: \(gameVM.scoresCalculated)")
                    print("🎯 Player selections count: \(gameVM.playerSelections.count)")
                    print("🎯 Imposter answers count: \(gameVM.imposterAnswers.count)")
                    
                    // Only calculate scores if this is NOT a disqualification scenario AND scores haven't been calculated yet
                    // AND all players have made their selections (to prevent premature bonus calculation)
                    if gameVM.disqualifiedPlayer == nil && !gameVM.scoresCalculated {
                        let legitimatePlayers = gameVM.players.filter { !$0.isImposter }
                        let imposters = gameVM.players.filter { $0.isImposter }
                        let allLegitimateSelected = legitimatePlayers.allSatisfy { gameVM.playerSelections[$0] != nil }
                        let allImpostersAnswered = imposters.allSatisfy { gameVM.imposterAnswers[$0] != nil }
                        
                        print("🎯 VALIDATION: All legitimate selected: \(allLegitimateSelected)")
                        print("🎯 VALIDATION: All imposters answered: \(allImpostersAnswered)")
                        
                        if allLegitimateSelected && allImpostersAnswered {
                            print("🎯 CALCULATING SCORES - All selections complete")
                            gameVM.scoresCalculated = true
                            calculateScores()
                        } else {
                            print("🎯 SKIPPING SCORE CALCULATION - Incomplete selections")
                            print("🎯 VALIDATION: All legitimate selected: \(allLegitimateSelected)")
                            print("🎯 VALIDATION: All imposters answered: \(allImpostersAnswered)")
                        }
                    } else if gameVM.disqualifiedPlayer != nil {
                        print("🎯 SKIPPING SCORE CALCULATION - Disqualification scenario")
                        print("🎯 DISQUALIFICATION DEBUG: Disqualified player: \(gameVM.disqualifiedPlayer?.name ?? "unknown")")
                        print("🎯 DISQUALIFICATION DEBUG: Current player scores:")
                        for player in gameVM.players {
                            print("🎯 DISQUALIFICATION DEBUG: \(player.name): \(player.score) points")
                        }
                    } else if gameVM.scoresCalculated {
                        print("🎯 SKIPPING SCORE CALCULATION - Already calculated")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func calculateScores() {
        // NEVER calculate scores during disqualification - they were already set correctly
        if gameVM.disqualifiedPlayer != nil {
            print("🚫 calculateScores() called during disqualification - ABORTING to preserve disqualification scores")
            return
        }
        
        print("🎯 Starting normal score calculation...")
        // Calculate scores based on correct/incorrect guesses
        for player in gameVM.players {
            if player.isImposter {
                // Imposter gets points ONLY if they select the CORRECT answer
                if let imposterAnswer = gameVM.imposterAnswers[player] {
                    // Check if the imposter selected the correct answer or a wrong answer
                    if imposterAnswer == gameVM.currentWord {
                        // Imposter selected correct answer - they get a point for being honest!
                        if let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) {
                            gameVM.players[idx].score += 1
                            print("🎯 SCORING: Imposter \(player.name) gets 1 point for selecting correct answer: '\(imposterAnswer)'")
                        }
                    } else {
                        // Imposter selected wrong answer - they get NO points (failed their mission)
                        print("🎯 SCORING: Imposter \(player.name) gets 0 points for selecting wrong answer: '\(imposterAnswer)' instead of correct: '\(gameVM.currentWord)'")
                    }
                }
            } else {
                // Legitimate players get points for guessing the imposter correctly
                if let guessedImposter = gameVM.playerSelections[player] {
                    if guessedImposter?.id == gameVM.imposter?.id {
                        // Correct imposter guess - legitimate player gets a point
                        if let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) {
                            gameVM.players[idx].score += 1
                            print("🎯 SCORING: Legitimate player \(player.name) gets 1 point for correctly guessing imposter \(guessedImposter?.name ?? "Unknown")")
                        }
                    } else {
                        // Wrong imposter guess - legitimate player gets NO points
                        print("🎯 SCORING: Legitimate player \(player.name) gets 0 points for incorrectly guessing \(guessedImposter?.name ?? "Unknown") instead of imposter \(gameVM.imposter?.name ?? "Unknown")")
                    }
                }
            }
        }
        
        // Check if imposter went undetected and award bonus point
        if let currentImposter = gameVM.imposter {
            let legitimatePlayers = gameVM.players.filter { !$0.isImposter }
            print("🎭 BONUS DEBUG: Checking bonus for imposter \(currentImposter.name)")
            print("🎭 BONUS DEBUG: Legitimate players: \(legitimatePlayers.map { $0.name })")
            
            let imposterWasDetected = legitimatePlayers.contains { player in
                if let guessedImposter = gameVM.playerSelections[player] {
                    let wasDetected = guessedImposter?.id == currentImposter.id
                    print("🎭 BONUS DEBUG: Player \(player.name) guessed \(guessedImposter?.name ?? "nil") - Detected: \(wasDetected)")
                    return wasDetected
                }
                print("🎭 BONUS DEBUG: Player \(player.name) has no guess")
                return false
            }
            
            print("🎭 BONUS DEBUG: Imposter was detected: \(imposterWasDetected)")
            
            if !imposterWasDetected {
                // Imposter went undetected - award bonus point
                if let idx = gameVM.players.firstIndex(where: { $0.id == currentImposter.id }) {
                    gameVM.players[idx].score += 1
                    print("🎭 BONUS: Imposter \(currentImposter.name) gets 1 bonus point for going undetected!")
                }
            } else {
                print("🎭 BONUS: Imposter \(currentImposter.name) was detected - no bonus point")
            }
        }
        
        // Determine winners
        let maxScore = gameVM.players.map { $0.score }.max() ?? 0
        gameVM.winners = gameVM.players.filter { $0.score == maxScore }
        gameVM.gameState = .gameOver
    }
    
    // MARK: - Helper Views
    
    private func disqualificationView(disqualifiedPlayer: Player) -> some View {
        VStack {
            Text("DISQUALIFICATION")
                .font(.title2)
                .foregroundColor(.red)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(gameVM.players, id: \.id) { player in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(player.name):")
                                    .font(.headline)
                                    .foregroundColor(player.isImposter ? .red : .green)
                                
                                if player.isImposter {
                                    Text("(IMPOSTER)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .italic()
                                } else {
                                    Text("(LEGITIMATE)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .italic()
                                }
                            }
                            
                            if player.id == disqualifiedPlayer.id {
                                Text("DISQUALIFIED")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .bold()
                            } else {
                                Text("Default Win")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                    .bold()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func normalGameResultsView() -> some View {
        VStack {
            Text("Players' Guesses:")
                .font(.title2)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(gameVM.players, id: \.id) { player in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(player.name):")
                                    .font(.headline)
                                    .foregroundColor(player.isImposter ? .red : .green)
                                
                                if player.isImposter {
                                    Text("(IMPOSTER)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .italic()
                                } else {
                                    Text("(LEGITIMATE)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .italic()
                                }
                            }
                            
                            if player.isImposter {
                                // Show imposter's answer correctness
                                if let imposterAnswer = gameVM.imposterAnswers[player] {
                                    let isCorrect = imposterAnswer == gameVM.currentWord
                                    HStack {
                                        Text("Answered correct:")
                                            .font(.subheadline)
                                        Text(isCorrect ? "Yes" : "No")
                                            .font(.subheadline)
                                            .foregroundColor(isCorrect ? .green : .red)
                                            .bold()
                                    }
                                } else {
                                    Text("Did not confirm task")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            } else {
                                // Show legitimate player's imposter guess
                                if let guessedImposter = gameVM.playerSelections[player] {
                                    HStack {
                                        Text("Guessed imposter:")
                                            .font(.subheadline)
                                        Text(guessedImposter?.name ?? "No Selection")
                                            .font(.subheadline)
                                            .foregroundColor(guessedImposter == gameVM.imposter ? .green : .red)
                                        .bold()
                                    }
                                } else {
                                    Text("No imposter selected")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    RevealImposterView(path: .constant([]))
        .environmentObject(GameViewModel())
}

// Mock Data
let mockPlayers: [Player] = [
    Player(name: "Alice", status: "True", score: 0, isImposter: false),
    Player(name: "Bob", status: "True", score: 0, isImposter: false),
    Player(name: "Charlie", status: "True", score: 0, isImposter: true),
    Player(name: "David", status: "True", score: 0, isImposter: false)
]

let mockImposter = mockPlayers[2] // Charlie is the imposter

let mockPlayerSelections: [Player: Player?] = [
    mockPlayers[0]: mockPlayers[2], // Alice guessed Charlie
    mockPlayers[1]: mockPlayers[2], // Bob guessed Charlie
    mockPlayers[3]: mockPlayers[1]  // David guessed Bob (wrong guess)
]
