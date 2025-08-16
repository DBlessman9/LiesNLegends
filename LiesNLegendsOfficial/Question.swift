//
//  Question.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI

struct Question: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    @State private var showQuestion = false
    @State private var questionOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top bar with speaker button
                HStack {
                    Spacer()
                    SpeakerButton()
                        .environmentObject(soundManager)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Question display
                VStack(spacing: 30) {
                    Text("Ready to test your knowledge?")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(questionOpacity)
                    
                    Text("Think carefully about your answer!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(questionOpacity)
                }
                
                Spacer()
                
                // Start guessing button
                Button {
                    // Navigate to GuessImposter with the current round players
                    path.append(.guessImposter)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 250, height: 60)
                            .background(Color.green)
                            .cornerRadius(50)
                        Text("START GUESSING")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .opacity(questionOpacity)
                .padding(.bottom, 50)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Animate the question appearance
            withAnimation(.easeIn(duration: 1.0)) {
                questionOpacity = 1.0
            }
        }
    }
}

#Preview {
    Question(path: .constant([]))
        .environmentObject(GameViewModel())
}
