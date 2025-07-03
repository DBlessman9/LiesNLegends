//
//  Sounds.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI
import AVFoundation

var player : AVAudioPlayer!

struct MusicView: View{
    @State private var isPlaying = false

var body: some View {
    VStack {
        
    }
   .padding()
  }
}

struct Haptics___Sound: View {
// declare an audio player at the view level
@State private var player: AVAudioPlayer?

var body: some View {
    Button("Tap Me") {
        SoundManager.shared.playSound(named: "CARD FLIP")
        SoundManager.shared.playHaptic()
    }
}
    
    func playSound(named soundName: String){
        SoundManager.shared.playSound(named: soundName)
    }
}


#Preview {
Haptics___Sound()
}
