//
//  ContentView.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation

struct ContFlipView: View {
    @State private var isFlipped = false
    @State private var angle: Double = 0
    
    var body: some View {
        ZStack {
            Image("CardBack")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
            
            Image("CardBack")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
        }
        .onAppear {
            startFlipping()
        }
    }
       
     func startFlipping() {
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.8)) {
                    angle += 180
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isFlipped.toggle()
                }
                
            }
        }
    }

struct CardFlipView: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @State private var angle: Double = 0
    @State private var isFlipped = false
    @State private var currentPlayerIndex = 0
    @State private var shuffledPlayers: [Player] = []
    @State private var hasFlipped: [Bool] = []
    
    var currentPlayer: Player {
        guard !shuffledPlayers.isEmpty, currentPlayerIndex < shuffledPlayers.count else {
            print("currentPlayerIndex \(currentPlayerIndex) out of bounds for shuffledPlayers (count: \(shuffledPlayers.count))")
            return Player(name: "Unknown", status: "N/A", score: 0)
        }
        return shuffledPlayers[currentPlayerIndex]
    }
    
    func playSound(named soundName: String){
        SoundManager.shared.playSound(named: soundName)
    }
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea(edges: .all)
            VStack {
                Text(currentPlayer.name)
                    .font(.system(size: 50, weight: .bold, design: .default))
                    .padding(.top, 50)
                
                ZStack {
                    if currentPlayer.isImposter {
                        // Imposter sees their unique card
                        Image("CardBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 400)
                            .shadow(color: .black, radius: 15, x: 5, y: 5)
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                        
                        Image("ImposCard")  // Imposter's unique card
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 450)
                            .shadow(color: .black, radius: 15, x: 5, y: 5)
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                    } else {
                        // Legitimates see the same card
                        Image("CardBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 400)
                            .shadow(color: .black, radius: 15, x: 5, y: 5)
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                        
                        Image("LegitCard")  // Legitimate card
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 450)
                            .shadow(color: .black, radius: 15, x: 5, y: 5)
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                        
                        Text(gameVM.currentWord)
                            .font(.title3)
                            .bold()
                            .padding(.top, 20)
                            .lineLimit(8)
                            .minimumScaleFactor(0.5)
                            .frame(width: 100, height: 200)
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button {
                    startFlipping()
                    SoundManager.shared.playSound(named: "CARD FLIP")
                    SoundManager.shared.playHaptic()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("FLIP CARD")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                
                Button {
                    passThePhone()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("PASS THE PHONE")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                
                NavigationLink(destination: Question(roundPlayers: shuffledPlayers, path: $path).environmentObject(gameVM)) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .font(.headline)
                            .frame(width: 200, height: 40)
                            .background(Color.white)
                            .cornerRadius(50)
                        Text("START ROUND")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("CardFlipView appeared. Players: \(gameVM.players.map { $0.name })")
            shuffledPlayers = gameVM.players.shuffled()
            hasFlipped = Array(repeating: false, count: gameVM.players.count)
        }
    }
    
    func startFlipping() {
        withAnimation(.easeInOut(duration: 0.4)) {
            angle += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isFlipped.toggle()
        }
        
        if let index = shuffledPlayers.firstIndex(where: { $0.id == currentPlayer.id }) {
            hasFlipped[index] = true
        }
    }
    
    func passThePhone() {
        print("Before increment: currentPlayerIndex = \(currentPlayerIndex), shuffledPlayers.count = \(shuffledPlayers.count)")
        if currentPlayerIndex < shuffledPlayers.count - 1 {
            currentPlayerIndex += 1
        } else {
            print("Attempted to increment past end of shuffledPlayers!")
        }
    }
    
    
    func assignImposter(from players: inout [Player]) -> (imposter: Player, legitimates: [Player]) {
        // Filter out players who are already imposters
        let nonImposters = players.filter { !$0.isImposter }
        
        // Guard clause to ensure there are non-imposter players to choose from
        guard !nonImposters.isEmpty else {
            // Return empty imposter and legitimates if no players exist
            return (imposter: Player(name: "No players", status: "None", score: 0, isImposter: false), legitimates: [])
        }
        
        // Generate a random index for the imposter from the remaining players
        let randomIndex = Int.random(in: 0..<nonImposters.count)
        
        // Get the selected imposter
        let imposter = nonImposters[randomIndex]
        
        // Update players list: Make sure imposter is added and others are marked as legitimate
        players = players.map { player in
            let updatedPlayer = player
            if updatedPlayer.id == imposter.id {
                let mutablePlayer = updatedPlayer
                // No mutation, just return
                return mutablePlayer
            } else {
                let mutablePlayer = updatedPlayer
                // No mutation, just return
                return mutablePlayer
            }
        }
        
        // Now create the list of legitimates (without the newly assigned imposter)
        let legitimates = players.filter { !$0.isImposter }
        
        // Return both the imposter and the legitimate players
        return (imposter: imposter, legitimates: legitimates)
    }

}

//example
#Preview {
    CardFlipView(path: .constant([])).environmentObject(GameViewModel())
}

//example players

      

