//
//  LiesNLegendsOfficialApp.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation


@main
struct LiesNlegendsApp: App {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var soundManager = SoundManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                StartScreen()
                    .environmentObject(gameVM)
                    .environmentObject(soundManager)
                    .modelContainer(for: Player.self, inMemory: true)
                    .onAppear{
                        print("App started")
                        soundManager.playBackgroundMusic(named: "GAME MUSIC")
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        // App going to background - keep music playing
                        print("App going to background")
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        // App coming to foreground - ensure music is playing
                        print("App coming to foreground")
                        if !soundManager.isBackgroundMusicPlaying {
                            soundManager.resumeBackgroundMusic()
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                        // App terminating - cleanup audio resources
                        print("App terminating")
                        soundManager.cleanup()
                    }
            }
        }
    }
}

