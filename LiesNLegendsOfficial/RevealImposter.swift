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
    
    func removeImposters(from players: inout [Player]) {
        players.removeAll { $0.isImposter }
    }
    
    var body: some View {
            VStack {
                Text("The Imposter was:")
                    .font(.title)
                    .padding()
                
                Text(gameVM.imposter?.name ?? "Unknown")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                
                Text("Players' Guesses:")
                    .font(.title2)
                    .padding(.top)
                
                ForEach(gameVM.players, id: \.id) { player in
                    HStack {
                        Text("\(player.name) guessed: ")
                            .font(.headline)
                        
                        if let guessedImposter = gameVM.playerSelections[player] {
                            Text(guessedImposter?.name ?? "No Selection")
                                .font(.headline)
                                .foregroundColor(guessedImposter == gameVM.imposter ? .green : .red)
                        } else {
                            Text("No Selection")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Button to restart or go to the next round
                NavigationLink(destination: ListOfPlayers(path: $path).environmentObject(gameVM),
                               label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("NEXT ROUND")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                })
                .padding()
            }
            .navigationTitle("Imposter Revealed")
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
