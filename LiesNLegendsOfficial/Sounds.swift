//
//  Sounds.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation

struct SpeakerButton: View {
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        Button(action: {
            if soundManager.isBackgroundMusicPlaying {
                soundManager.pauseBackgroundMusic()
            } else {
                soundManager.resumeBackgroundMusic()
            }
        }) {
            Image(systemName: soundManager.isBackgroundMusicPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                )
        }
        .animation(.easeInOut(duration: 0.2), value: soundManager.isBackgroundMusicPlaying)
    }
}

struct MusicView: View {
    @EnvironmentObject var soundManager: SoundManager
    @State private var showMusicControls = false
    
    var body: some View {
        VStack {
            // Music control button
            Button(action: {
                showMusicControls.toggle()
            }) {
                Image(systemName: soundManager.isBackgroundMusicPlaying ? "music.note" : "music.note.list")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.7))
                    )
            }
            
            // Music controls panel
            if showMusicControls {
                VStack(spacing: 12) {
                    // Play/Pause button
                    Button(action: {
                        if soundManager.isBackgroundMusicPlaying {
                            soundManager.pauseBackgroundMusic()
                        } else {
                            soundManager.resumeBackgroundMusic()
                        }
                    }) {
                        Image(systemName: soundManager.isBackgroundMusicPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.8))
                            )
                    }
                    
                    // Background music volume slider
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Music")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Slider(value: Binding(
                                get: { Double(soundManager.backgroundMusicVolume) },
                                set: { soundManager.setBackgroundMusicVolume(Float($0)) }
                            ), in: 0...1)
                            .accentColor(.white)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    
                    // Sound effects volume slider
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SFX")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Slider(value: Binding(
                                get: { Double(soundManager.soundEffectsVolume) },
                                set: { soundManager.setSoundEffectsVolume(Float($0)) }
                            ), in: 0...1)
                            .accentColor(.white)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showMusicControls)
    }
}

struct Haptics___Sound: View {
    var body: some View {
        Button("Tap Me") {
            SoundManager.shared.playSound(named: "CARD FLIP")
            SoundManager.shared.playHaptic()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeakerButton()
            .environmentObject(SoundManager.shared)
        MusicView()
            .environmentObject(SoundManager.shared)
    }
    .background(Color.gray)
}
