//
//  ScoreBoard.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI

struct ScoreBoard: View {
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
                
                Text("Final Scores")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                
                // Show round information - display the completed round
                Text("Round \(gameVM.currentRound)")
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                    .padding(.bottom, 10)
                
                // Display players and their scores
                if !gameVM.players.isEmpty {
                    List(gameVM.players) { player in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Player")
                                    .font(.headline)
                                Spacer()
                                Text(player.name)
                                    .bold()
                                Spacer()
                                Text("\(player.score)")
                                    .font(.title2)
                                    .bold()
                            }
                            
                            // Show player role and what they guessed
                            HStack {
                                Text(player.isImposter ? "IMPOSTER" : "LEGITIMATE")
                                    .font(.caption)
                                    .foregroundColor(player.isImposter ? .red : .green)
                                    .bold()
                                
                                Spacer()
                                
                                if player.isImposter {
                                    if let imposterAnswer = gameVM.imposterAnswers[player] {
                                        let isCorrect = imposterAnswer == gameVM.currentWord
                                        Text("Answered correct: \(isCorrect ? "Yes" : "No")")
                                            .font(.caption)
                                            .foregroundColor(isCorrect ? .green : .red)
                                    }
                                } else {
                                    if let guessedImposter = gameVM.playerSelections[player] {
                                        Text("Guessed: \(guessedImposter?.name ?? "None")")
                                            .font(.caption)
                                            .foregroundColor(guessedImposter == gameVM.imposter ? .green : .red)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 400)
                }
                
                // Show winners if game is over
                if !gameVM.players.isEmpty {
                    VStack {
                        if !gameVM.winners.isEmpty && gameVM.winners.first?.score ?? 0 > 0 {
                            Text("🏆 Winners! 🏆")
                                .font(.title)
                                .bold()
                                .foregroundColor(.orange)
                                .padding()
                            
                            ForEach(gameVM.winners) { winner in
                                Text(winner.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                        } else {
                            Text("😔 No one won")
                                .font(.title)
                                .bold()
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    Button("Play Again") {
                        // If there was a disqualification, use special logic
                        if gameVM.disqualifiedPlayer != nil {
                            gameVM.continueAfterDisqualification()
                        } else {
                            gameVM.continueToNextRound()
                        }
                        path.append(.pickCategory)
                    }
                    .buttonStyle(GameButtonStyle())
                    
                    Button("New Game") {
                        // Navigate back to start screen FIRST
                        path = []
                        
                        // Then clear all game data after navigation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            gameVM.resetForNewGame()
                        }
                    }
                    .buttonStyle(GameButtonStyle())
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Custom button style for consistency
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .stroke(.black, lineWidth: 6)
                .frame(width: 150, height: 40)
                .background(Color.white)
                .cornerRadius(50)
            
            configuration.label
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ScoreBoard(path: .constant([]))
        .environmentObject(GameViewModel())
}


