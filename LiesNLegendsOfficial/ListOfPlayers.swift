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
    @State private var newName = ""
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
                
                Button {
                    let trimmedName = newName.trimmingCharacters(in: .whitespaces)
                    
                    guard !trimmedName.isEmpty else { return }
                    guard gameVM.players.count < maxPlayers else {
                        print("Cannot add more than \(maxPlayers) players.")
                        return
                    }
                    gameVM.addPlayer(name: trimmedName)
                    newName = ""
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
                
                
                
                
                
                NavigationLink(destination: PickACategory(path: $path).environmentObject(gameVM)) {
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
                
                .disabled(gameVM.players.count < minPlayers)
                
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
