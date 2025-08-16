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
    @EnvironmentObject var soundManager: SoundManager
    @State private var angle: Double = 0
    @State private var isFlipped = false
    @State private var currentPlayerIndex = 0
    @State private var shuffledPlayers: [Player] = []
    @State private var hasFlipped: [Bool] = []
    
    // New state variables for swipe animations
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var isAnimating = false
    
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
                // Top bar with speaker button
                HStack {
                    Spacer()
                    SpeakerButton()
                        .environmentObject(soundManager)
                        .padding(.top, 0)
                        .padding(.trailing, 20)
                        .padding(.bottom, -30)
                }
                
                Text(currentPlayer.name)
                    .font(.system(size: 50, weight: .bold, design: .default))
                    .padding(.top, 5)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                // Show player counter
                Text("Player \(currentPlayerIndex + 1) of \(shuffledPlayers.count)")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, -13)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                // Show round information
                Text("Round \(gameVM.currentRound)")
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                    .padding(.bottom, -13)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                // Show player role instruction only when card is face up
                if isFlipped {
                    if currentPlayer.isImposter {
                        Text("You are the IMPOSTER!")
                            .font(.title2)
                            .foregroundColor(.red)
                            .bold()
                            .padding(.bottom, 10)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        

                    } else {
                        Text("You are LEGITIMATE")
                            .font(.title2)
                            .foregroundColor(.green)
                            .bold()
                            .padding(.bottom, 10)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        

                    }
                }
                
                // Card with navigation buttons on sides
                HStack(spacing: -30) { // Reduced from -15 to -30 (15 points closer)
                    // Left navigation button (previous player)
                    Button(action: {
                        if currentPlayerIndex > 0 && !isAnimating {
                            animateCardTransition(direction: .right) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex -= 1
                                    // Reset card state for previous player
                                    isFlipped = false
                                    angle = 0
                                }
                                print("Navigated back to player \(shuffledPlayers[currentPlayerIndex].name)")
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .opacity(currentPlayerIndex > 0 ? 1.0 : 0.3)
                    }
                    .disabled(currentPlayerIndex == 0 || isAnimating)
                    
                    // Main card
                    ZStack {
                        if currentPlayer.isImposter {
                            // Imposter sees they are the imposter, NOT the correct answer
                            Image("CardBack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 400)
                                .shadow(color: .black, radius: 15, x: 5, y: 5)
                                .opacity(isFlipped ? 0 : 1)
                                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                                .offset(x: cardOffset)
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                            
                            Image("ImposCard")  // Imposter sees the imposter card
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 450)
                                .shadow(color: .black, radius: 15, x: 5, y: 5)
                                .opacity(isFlipped ? 1 : 0)
                                .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                                .offset(x: cardOffset)
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                            
                            // Imposter card is blank - no text revealed
                        } else {
                            // Legitimates see the same card
                            Image("CardBack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 400)
                                .shadow(color: .black, radius: 15, x: 5, y: 5)
                                .opacity(isFlipped ? 0 : 1)
                                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                                .offset(x: cardOffset)
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                            
                            Image("LegitCard")  // Legitimate card
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 450)
                                .shadow(color: .black, radius: 15, x: 5, y: 5)
                                .opacity(isFlipped ? 1 : 0)
                                .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                                .offset(x: cardOffset)
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                            
                            Text(gameVM.currentWord)
                                .font(.title3)
                                .bold()
                                .padding(.top, 20)
                                .lineLimit(8)
                                .minimumScaleFactor(0.5)
                                .frame(width: 100, height: 200)
                                .opacity(isFlipped ? 1 : 0)
                                .rotation3DEffect(.degrees(angle + 180), axis: (x: 0, y: 1, z: 0))
                                .offset(x: cardOffset)
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: cardOffset)
                    .animation(.easeInOut(duration: 0.4), value: cardRotation)
                    .animation(.easeInOut(duration: 0.4), value: cardScale)
                    
                    // Right navigation button (next player)
                    Button(action: {
                        if currentPlayerIndex < shuffledPlayers.count - 1 && !isAnimating {
                            animateCardTransition(direction: .left) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex += 1
                                    // Reset card state for next player
                                    isFlipped = false
                                    angle = 0
                                }
                                print("Navigated forward to player \(shuffledPlayers[currentPlayerIndex].name)")
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .opacity(currentPlayerIndex < shuffledPlayers.count - 1 ? 1.0 : 0.3)
                    }
                    .disabled(currentPlayerIndex == shuffledPlayers.count - 1 || isAnimating)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // Progress counter right below the card
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<shuffledPlayers.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPlayerIndex ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.top, -5)
                }
                
                // Flip Button - always show to allow flipping back down
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
                        Text(isFlipped ? "FLIP BACK" : "FLIP CARD")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // START ROUND button - appears when last player is reached
                if currentPlayerIndex == shuffledPlayers.count - 1 {
                    Button {
                        soundManager.playSound(named: "CARD FLIP")
                        gameVM.startNewRound()
                        // Navigate to Question view with roundPlayers
                        path.append(.question)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .frame(width: 250, height: 50)
                                .background(Color.white)
                                .cornerRadius(50)
                            Text("START ROUND")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 0)
                }
                
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isAnimating {
                        // Real-time card movement during drag
                        let dragAmount = value.translation.width
                        cardOffset = dragAmount * 0.3 // Reduce movement for subtle effect
                        cardRotation = Double(dragAmount) * 0.1 // Slight rotation during drag
                        cardScale = 1.0 - abs(dragAmount) * 0.0005 // Slight scale down during drag
                    }
                }
                .onEnded { value in
                    let swipeThreshold: CGFloat = 50
                    
                    if value.translation.width > swipeThreshold {
                        // Swipe right - go back to previous player
                        if currentPlayerIndex > 0 && !isAnimating {
                            animateCardTransition(direction: .right) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex -= 1
                                    // Reset card state for previous player
                                    isFlipped = false
                                    angle = 0
                                }
                                print("Swiped back to player \(shuffledPlayers[currentPlayerIndex].name)")
                            }
                        } else {
                            // Reset card position if swipe not valid
                            resetCardPosition()
                        }
                    } else if value.translation.width < -swipeThreshold {
                        // Swipe left - go to next player
                        if currentPlayerIndex < shuffledPlayers.count - 1 && !isAnimating {
                            animateCardTransition(direction: .left) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex += 1
                                    // Reset card state for next player
                                    isFlipped = false
                                    angle = 0
                                }
                                print("Swiped forward to player \(shuffledPlayers[currentPlayerIndex].name)")
                            }
                        } else {
                            // Reset card position if swipe not valid
                            resetCardPosition()
                        }
                    } else {
                        // Reset card position if swipe not strong enough
                        resetCardPosition()
                    }
                }
        )
        .onTapGesture {
            // Tap-to-flip functionality - works both ways
            if !isAnimating {
                startFlipping()
                SoundManager.shared.playSound(named: "CARD FLIP")
                SoundManager.shared.playHaptic()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("CardFlipView appeared. Players: \(gameVM.players.map { $0.name })")
            // Always create a fresh shuffled players array for the new round
            shuffledPlayers = gameVM.players.shuffled()
            // Reset the hasFlipped array for the new round
            hasFlipped = Array(repeating: false, count: gameVM.players.count)
            // Reset current player index for the new round
            currentPlayerIndex = 0
            // Reset card state for the new round
            isFlipped = false
            angle = 0
            // Reset animation states
            cardOffset = 0
            cardRotation = 0
            cardScale = 1.0
            isAnimating = false
        }
    }
    
    // New function to animate card transitions
    private func animateCardTransition(direction: SwipeDirection, completion: @escaping () -> Void) {
        isAnimating = true
        
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let exitOffset: CGFloat = direction == .left ? -screenWidth : screenWidth
        let exitRotation: Double = direction == .left ? -15 : 15
        
        // Animate card exit
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOffset = exitOffset
            cardRotation = exitRotation
            cardScale = 0.8
        }
        
        // After exit animation, reset and animate new card in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Reset card position off-screen in opposite direction
            cardOffset = direction == .left ? screenWidth : -screenWidth
            cardRotation = direction == .left ? 15 : -15
            cardScale = 0.8
            
            // Execute the completion (player change)
            completion()
            
            // Animate new card in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.4)) {
                    cardOffset = 0
                    cardRotation = 0
                    cardScale = 1.0
                }
                
                // Reset animation state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isAnimating = false
                }
            }
        }
    }
    
    // Function to reset card position
    private func resetCardPosition() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = 0
            cardRotation = 0
            cardScale = 1.0
        }
    }
    
    func startFlipping() {
        withAnimation(.easeInOut(duration: 0.4)) {
            angle += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isFlipped.toggle()
            
            // Mark player as having seen their card when they flip it up
            if isFlipped {
                if let index = shuffledPlayers.firstIndex(where: { $0.id == currentPlayer.id }) {
                    hasFlipped[index] = true
                    print("Player \(currentPlayer.name) flipped card UP. hasFlipped[\(index)] = true")
                    print("Current hasFlipped array: \(hasFlipped)")
                } else {
                    print("ERROR: Could not find player \(currentPlayer.name) in shuffledPlayers")
                }
            }
        }
    }
    
    func passThePhone() {
        print("Before increment: currentPlayerIndex = \(currentPlayerIndex), shuffledPlayers.count = \(shuffledPlayers.count)")
        if currentPlayerIndex < shuffledPlayers.count - 1 {
            currentPlayerIndex += 1
            print("Passed phone to player \(shuffledPlayers[currentPlayerIndex].name)")
            // Reset card state for next player
            isFlipped = false
            angle = 0
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

// Enum for swipe direction
enum SwipeDirection {
    case left
    case right
}

//example
#Preview {
    CardFlipView(path: .constant([])).environmentObject(GameViewModel())
}

//example players

      

