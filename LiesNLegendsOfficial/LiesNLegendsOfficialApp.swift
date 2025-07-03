//
//  LiesNLegendsOfficialApp.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation


@main
struct LiesNLegendsApp: App {
    @StateObject private var gameVM = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                StartScreen()
                    .environmentObject(gameVM)
                    .modelContainer(for: Player.self, inMemory: true)
                    .onAppear{
                        print("App started")
                        SoundManager.shared.playSound(named: "GAME MUSIC", numberOfLoops: -1)
                    }
               
                
            }
        }
        
    }
}

