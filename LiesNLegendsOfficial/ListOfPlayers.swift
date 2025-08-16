//
//  ListOfPlayers.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import SwiftData
import UIKit

// Player Model: Conforming to Identifiable

// Helper extension to dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ListOfPlayers: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    @State private var newName = ""
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    let minPlayers = 4
    let maxPlayers = 6

//    var playerID: Int {
//        return players.count + 1
//    }

        var body: some View {
        ZStack {
            // Tap to dismiss keyboard
            Color(.background)
                .ignoresSafeArea(edges: .all)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
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
                Text("Add Players")
                    .font(.largeTitle)
                    .bold()
                Text("Minimum 4 Players")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 10)
                
                List(gameVM.players) { player in
                    HStack {
                        Text(player.name)
                            .bold(player.isTurn)
                        Spacer()
                        Button("x") {
                            gameVM.removePlayer(player)
                        }
                        .font(.caption)
                        .foregroundStyle(Color(.background))
                    }
                }
                .listStyle(.sidebar)
                
            
                Spacer()
                TextField("Enter player name (Max: 6 Players)", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 350)
                
                // Feedback message
                if showFeedback {
                    Text(feedbackMessage)
                        .foregroundColor(feedbackMessage.contains("✅") ? .green : .red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button {
                    let trimmedName = newName.trimmingCharacters(in: .whitespaces)
                    
                    guard !trimmedName.isEmpty else { 
                        feedbackMessage = "❌ Please enter a player name"
                        showFeedback = true
                        return 
                    }
                    guard gameVM.players.count < maxPlayers else {
                        feedbackMessage = "❌ Cannot add more than \(maxPlayers) players"
                        showFeedback = true
                        return
                    }
                    
                    // Store current count to check if player was added
                    let currentCount = gameVM.players.count
                    gameVM.addPlayer(name: trimmedName)
                    
                    // Check if player was actually added
                    if gameVM.players.count > currentCount {
                        feedbackMessage = "✅ Player '\(trimmedName)' added successfully"
                        newName = ""
                    } else {
                        feedbackMessage = "❌ Player '\(trimmedName)' could not be added (duplicate name)"
                    }
                    showFeedback = true
                    
                    // Hide feedback after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showFeedback = false
                    }
                } label: {
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("ADD PLAYER")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .disabled(gameVM.players.count >= maxPlayers)

                Button{
                    gameVM.clearPlayers()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.red, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("CLEAR ALL")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                    
                
                
                
                
                Spacer()
                
                
                
                
                
                NavigationLink(destination: PickACategory(path: $path).environmentObject(gameVM).environmentObject(soundManager)) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                            
                        Text("START GAME")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                    }
                    
                }
                .disabled(!gameVM.canStartGame())
                
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    print("Logout button tapped, clearing path")
                    path = [] // Pops to StartScreen
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ListOfPlayers(path: .constant([]))
        .environmentObject(GameViewModel())
        .modelContainer(for: Player.self, inMemory: true)
}
