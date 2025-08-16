//
//  StartScreen.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation

struct StartScreen: View {
    @State private var showRules = false
    @State private var path: [AppRoute] = []
    @Environment(\.modelContext) private var context
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.gray.frame(width: 4100, height: 9000)
                
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
                        .padding()
                    //                CardFlipView()
                        .padding(.bottom, 30)
                    
                    ContFlipView()
                        .padding(.bottom, 30)
                    
                    Button {
                        path.append(.players)
                    } label: {
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
                    .padding(.bottom, 10)
                    
                    Button(action: {showRules.toggle()}){
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.white)
                                .cornerRadius(50)
                            Text("RULES")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    .sheet(isPresented: $showRules) {
                        RulesScreen()
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .players:
                    ListOfPlayers(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .pickCategory:
                    PickACategory(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .cardFlip:
                    CardFlipView(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .question:
                    Question(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .guessImposter:
                    GuessTheImposter(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .revealImposter:
                    RevealImposterView(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                case .scoreboard:
                    ScoreBoard(path: $path)
                        .environmentObject(gameVM)
                        .environmentObject(soundManager)
                }
            }
        }
    }
}

#Preview {
   StartScreen()
        .environmentObject(GameViewModel())
        .modelContainer(for: Player.self, inMemory: true)
}
