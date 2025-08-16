//
//  Untitled.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI

struct GuessTheImposter: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    @State private var currentPlayerIndex = 0
    @State private var isFlipped = false
    @State private var selectedImposter: Player? // Store selected imposter for legitimate players
    @State private var selectedAnswer: String? // Store selected answer for imposters
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var isAnimating = false
    @State private var popupText: String? = nil
    @State private var stableAnswerOptions: [String] = []
    
    var currentPlayer: Player {
        gameVM.players[currentPlayerIndex]
    }
    
    var shouldShowPopup: Bool {
        popupText != nil
    }
    
    var imposterAnswerOptions: [String] {
        // Return stable options if they exist, otherwise generate new ones
        if !stableAnswerOptions.isEmpty {
            return stableAnswerOptions
        }
        
        // Get possible answers from the current category
        let possibleAnswers = getPossibleAnswers()
        
        // Create a set to ensure uniqueness
        var uniqueAnswers = Set(possibleAnswers)
        
        // Remove the correct answer temporarily to avoid duplicates
        uniqueAnswers.remove(gameVM.currentWord)
        
        // Convert to array and shuffle
        let shuffledAnswers = Array(uniqueAnswers).shuffled()
        
        // Take exactly 5 random unique answers (or all if less than 5)
        let randomCount = min(5, shuffledAnswers.count)
        let selectedRandomAnswers = Array(shuffledAnswers.prefix(randomCount))
        
        // Add the correct answer
        let finalAnswers = selectedRandomAnswers + [gameVM.currentWord]
        
        // Shuffle the final result to randomize the position of the correct answer
        let shuffledFinal = finalAnswers.shuffled()
        
        // Store the stable options
        stableAnswerOptions = shuffledFinal
        
        // Debug: Print the final options to see what's being generated
        print("🎲 IMPOSTER OPTIONS: Generated \(shuffledFinal.count) options:")
        for (index, option) in shuffledFinal.enumerated() {
            print("🎲 IMPOSTER OPTIONS: [\(index)] \(option)")
        }
        
        return shuffledFinal
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top section with player name and navigation
                topNavigationSection
                
                Spacer()
                
                // Card section
                cardSection
                
                // Progress bubbles positioned below the card
                HStack(spacing: 4) {
                    ForEach(0..<gameVM.players.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPlayerIndex ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 10)
                
                // Bottom section with flip button and disqualify button
                bottomSection
            }
        }
        .overlay(
            // Full text popup overlay - render at the very top level
            Group {
                if shouldShowPopup {
                    fullTextPopup(popupText!)
                        .zIndex(9999)
                        .allowsHitTesting(true)
                }
            }
        )
        .onAppear {
            // Reset stable answer options when view appears (new game/category)
            stableAnswerOptions = []
            
            // Initialize player selections to nil for each player
            gameVM.players.forEach { player in
                if gameVM.playerSelections[player] == nil {
                    gameVM.playerSelections[player] = nil
                }
            }
            // Set current player's selection if they already made one
            if currentPlayer.isImposter {
                selectedAnswer = gameVM.imposterAnswers[currentPlayer]
            } else {
                selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
            }
            
            // Debug popup state
            print("🎭 POPUP: View appeared - popupText: \(popupText ?? "nil")")
            print("🎭 POPUP: Category: \(gameVM.currentCategory)")
            print("🎭 POPUP: shouldShowPopup: \(shouldShowPopup)")
            print("🎭 POPUP: Current player is imposter: \(currentPlayer.isImposter)")
            print("🎭 POPUP: Available answers count: \(imposterAnswerOptions.count)")
            print("🎭 POPUP: Available answers: \(imposterAnswerOptions)")
            print("🎭 POPUP: Current word: \(gameVM.currentWord)")
        }
    }
    
    // MARK: - View Components
    
    private var topNavigationSection: some View {
        VStack {
            // Mute button positioned above the arrows, aligned to the right
            HStack {
                Spacer()
                SpeakerButton()
                    .environmentObject(soundManager)
                    .padding(.trailing, 20)
            }
            
            HStack {
                // Left arrow - go to previous player
                Button(action: {
                    if currentPlayerIndex > 0 {
                        animateCardTransition(direction: .right) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPlayerIndex -= 1
                                isFlipped = false
                                if currentPlayer.isImposter {
                                    selectedAnswer = gameVM.imposterAnswers[currentPlayer]
                                } else {
                                    selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
                                }
                            }
                        }
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .disabled(currentPlayerIndex == 0)
                
                Spacer()
                
                // Player name
                Text(currentPlayer.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                Spacer()
                
                // Right arrow - go to next player
                Button(action: {
                    if currentPlayerIndex < gameVM.players.count - 1 {
                        animateCardTransition(direction: .left) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPlayerIndex += 1
                                isFlipped = false
                                if currentPlayer.isImposter {
                                    selectedAnswer = gameVM.imposterAnswers[currentPlayer]
                                } else {
                                    selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
                                }
                            }
                        }
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .disabled(currentPlayerIndex == gameVM.players.count - 1)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
    }
    
    private var cardSection: some View {
        ZStack {
            // Card Back
            Image("CardBack")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .shadow(color: .black, radius: 15, x: 5, y: 5)
                .opacity(isFlipped ? 0 : 1)
                .offset(x: cardOffset)
                .rotationEffect(.degrees(cardRotation))
                .scaleEffect(cardScale)
            
            // Card content when flipped
            if isFlipped {
                flippedCardContent
                    .offset(x: cardOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .scaleEffect(cardScale)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isAnimating {
                        let dragAmount = value.translation.width
                        cardOffset = dragAmount * 0.3
                        cardRotation = Double(dragAmount) * 0.1
                        cardScale = 1.0 - abs(dragAmount) * 0.0005
                    }
                }
                .onEnded { value in
                    let swipeThreshold: CGFloat = 50
                    let dragAmount = value.translation.width
                    
                    if abs(dragAmount) > swipeThreshold {
                        if dragAmount > 0 && currentPlayerIndex > 0 {
                            // Swipe right - go to previous player
                            animateCardTransition(direction: .right) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex -= 1
                                    isFlipped = false
                                    if currentPlayer.isImposter {
                                        selectedAnswer = gameVM.imposterAnswers[currentPlayer]
                                    } else {
                                        selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
                                    }
                                }
                            }
                        } else if dragAmount < 0 && currentPlayerIndex < gameVM.players.count - 1 {
                            // Swipe left - go to next player
                            animateCardTransition(direction: .left) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPlayerIndex += 1
                                    isFlipped = false
                                    if currentPlayer.isImposter {
                                        selectedAnswer = gameVM.imposterAnswers[currentPlayer]
                                    } else {
                                        selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
                                    }
                                }
                            }
                        } else {
                            resetCardPosition()
                        }
                    } else {
                        resetCardPosition()
                    }
                }
        )
        .onTapGesture {
            // Tap-to-flip functionality (only flip up, not back)
            if !isFlipped {
                SoundManager.shared.playSound(named: "CARD FLIP")
                SoundManager.shared.playHaptic()
                flipCard()
            }
        }
    }
    
    private var flippedCardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: 300, height: 400)
            
            VStack {
                if currentPlayer.isImposter {
                    imposterGuessingContent
                } else {
                    legitimatePlayerContent
                }
            }
            .padding()
        }
    }
    
    private var imposterGuessingContent: some View {
        VStack {
            Text("Guess the Correct Answer")
                .font(.title2)
                .foregroundColor(.red)
                .padding(.top)
            
            if gameVM.currentCategory == "Sayings" {
                // Special UI for Sayings category - only 6 options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(Array(imposterAnswerOptions.enumerated()), id: \.offset) { index, answer in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.black, lineWidth: 2)
                                .frame(width: 180, height: 80)
                                .background(gameVM.imposterAnswers[currentPlayer] == answer ? Color.red : Color.white)
                                .cornerRadius(12)
                                .onAppear {
                                    print("🎨 BUTTON: Button for '\(answer)' - isSelected: \(gameVM.imposterAnswers[currentPlayer] == answer)")
                                    print("🎨 BUTTON: Current player: \(currentPlayer.name)")
                                    print("🎨 BUTTON: Current imposter answers: \(gameVM.imposterAnswers)")
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(gameVM.imposterAnswers[currentPlayer] == answer ? Color.red : Color.clear, lineWidth: 3)
                                )
                            
                            VStack(spacing: 4) {
                                Text(shortenTextForSayings(answer))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(gameVM.imposterAnswers[currentPlayer] == answer ? .white : .black)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 12)
                                
                                if answer.count > 25 {
                                    Text("Hold to see full saying")
                                        .font(.caption2)
                                        .foregroundColor(gameVM.imposterAnswers[currentPlayer] == answer ? .white.opacity(0.8) : .gray)
                                }
                            }
                        }
                        .onTapGesture {
                            print("🔍 POPUP: Single tap detected on answer: \(answer)")
                            print("🔍 POPUP: Answer length: \(answer.count)")
                            print("🔍 POPUP: Setting imposter answer for \(currentPlayer.name)")
                            print("🔍 POPUP: Current player object: \(currentPlayer)")
                            print("🔍 POPUP: Current imposter answers before: \(gameVM.imposterAnswers)")
                            gameVM.imposterAnswers[currentPlayer] = answer
                            print("🔍 POPUP: Imposter \(currentPlayer.name) guessed: \(answer)")
                            print("🔍 POPUP: Current imposter answers after: \(gameVM.imposterAnswers)")
                            print("🔍 POPUP: Will button show as selected? \(gameVM.imposterAnswers[currentPlayer] == answer)")
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            print("🔍 POPUP: Long press detected on answer: \(answer)")
                            print("🔍 POPUP: Answer count: \(answer.count)")
                            print("🔍 POPUP: Current category: \(gameVM.currentCategory)")
                            print("🔍 POPUP: Current player: \(currentPlayer.name)")
                            print("🔍 POPUP: Current player is imposter: \(currentPlayer.isImposter)")
                            if answer.count > 25 {
                                print("🔍 POPUP: Answer is long enough, calling showFullTextPopup")
                                showFullTextPopup(answer)
                            } else {
                                print("🔍 POPUP: Answer too short, not showing popup")
                            }
                        }
                    }
                }
                .padding(.horizontal, -14)
            } else {
                // Standard UI for other categories - only 6 options
                VStack(spacing: 8) {
                    ForEach(imposterAnswerOptions, id: \.self) { answer in
                        Button(action: {
                            gameVM.imposterAnswers[currentPlayer] = answer
                            print("Imposter \(currentPlayer.name) guessed: \(answer)")
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.black, lineWidth: 3)
                                    .frame(width: 190, height: 45)
                                    .background(gameVM.imposterAnswers[currentPlayer] == answer ? Color.red.opacity(0.3) : Color.white)
                                    .cornerRadius(25)
                                
                                Text(answer)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
            

        }
    }
    
    private var legitimatePlayerContent: some View {
        VStack {
            Text("Select the Imposter")
                .font(.title2)
                .padding(.top)
            
                                ForEach(gameVM.players, id: \.id) { player in
                Button(action: {
                    selectedImposter = player
                    gameVM.playerSelections[currentPlayer] = player
                    print("Player \(currentPlayer.name) selected \(player.name) as imposter")
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 6)
                            .frame(width: 200, height: 40)
                            .background(selectedImposter == player ? Color.green.opacity(0.5) : Color.white)
                            .cornerRadius(50)
                        
                        Text(player.name)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .padding(2)
            }
        }
    }
    
    private func fullTextPopup(_ text: String) -> some View {
        ZStack {
            // Background overlay - very transparent green
            Color.green.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        popupText = nil
                    }
                }
            
            // Popup content
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            popupText = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text("Full Saying")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
                
                ScrollView {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxHeight: 200)
                
                Text("Tap outside to close")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.7))
                    .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green.opacity(0.8), lineWidth: 2)
                    )
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.2), value: popupText != nil)
    }
    
    private var bottomSection: some View {
        VStack(spacing: 20) {
            // FLIP CARD button
            Button(action: {
                SoundManager.shared.playSound(named: "CARD FLIP")
                SoundManager.shared.playHaptic()
                flipCard()
            }) {
                Text("FLIP CARD")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                    .frame(width: 200, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 3)
                            .fill(Color.white)
                    )
            }
            .padding(.vertical, 10)
            
            // Disqualify button positioned below the flip card button
            Button(action: {
                gameVM.disqualifyPlayer(currentPlayer)
                // Navigate to reveal imposter view
                path.append(.revealImposter)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.red, lineWidth: 4)
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                    Text("DISQUALIFY")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 5)
            
            // Next Player button
                            if hasSelection && currentPlayerIndex < gameVM.players.count - 1 {
                Button(action: {
                    moveToNextPlayer()
                }) {
                    Text("Next Player")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                                .fill(Color.green)
                        )
                }
            }
            
            // Reveal Results button
            if allPlayersHaveSelected {
                Button(action: {
                    path.append(.revealImposter)
                }) {
                    Text("Reveal Results")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                                .fill(Color.green)
                        )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasSelection: Bool {
        currentPlayer.isImposter ? 
            (gameVM.imposterAnswers[currentPlayer] != nil) : 
            (gameVM.playerSelections[currentPlayer] != nil)
    }
    
    private var allPlayersHaveSelected: Bool {
        let legitimatePlayers = gameVM.players.filter { !$0.isImposter }
        let imposters = gameVM.players.filter { $0.isImposter }
        let allLegitimateSelected = legitimatePlayers.allSatisfy { gameVM.playerSelections[$0] != nil }
        let allImpostersAnswered = imposters.allSatisfy { gameVM.imposterAnswers[$0] != nil }
        return allLegitimateSelected && allImpostersAnswered
    }
    
    // MARK: - Functions
    
    func flipCard() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isFlipped.toggle()
        }
    }
    
    func moveToNextPlayer() {
        print("🎭 moveToNextPlayer called:")
        print("🎭 Current index before: \(currentPlayerIndex)")
        print("🎭 Current player before: \(gameVM.players[currentPlayerIndex].name)")
        print("🎭 Total players: \(gameVM.players.count)")
        
        if currentPlayerIndex < gameVM.players.count - 1 {
            currentPlayerIndex += 1
            isFlipped = false
            print("🎭 Moved to next player:")
            print("🎭 New index: \(currentPlayerIndex)")
            print("🎭 New player: \(gameVM.players[currentPlayerIndex].name)")
            print("🎭 New player isImposter: \(gameVM.players[currentPlayerIndex].isImposter)")
            
            if currentPlayer.isImposter {
                selectedAnswer = gameVM.imposterAnswers[currentPlayer]
            } else {
                selectedImposter = gameVM.playerSelections[currentPlayer] ?? nil
            }
        } else {
            print("🎭 All players have gone, moving to reveal phase")
        }
    }
    
    func animateCardTransition(direction: SwipeDirection, completion: @escaping () -> Void) {
        isAnimating = true
        
        withAnimation(.easeInOut(duration: 0.3)) {
            switch direction {
            case .left:
                cardOffset = -400
                cardRotation = -15
                cardScale = 0.8
            case .right:
                cardOffset = 400
                cardRotation = 15
                cardScale = 0.8
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
            resetCardPosition()
            isAnimating = false
        }
    }
    
    func resetCardPosition() {
        cardOffset = 0
        cardRotation = 0
        cardScale = 1.0
    }
    
    func getPossibleAnswers() -> [String] {
        // Return possible answers based on the current category
        switch gameVM.currentCategory {
        case "Motown":
            return ["David Ruffin", "Aretha Franklin", "Marvin Gaye", "Smokey Robinson", "Rick James", "Prince", "Martha Reeves", "Diana Ross", "Jackson 5", "Berry Gordy", "Stevie Wonder", "The Temptations", "The Isley Brothers", "The Miracles", "Al Green"]
        case "History":
            return ["Garret Morgan", "Madame CJ Walker", "Mary Ellen Pleasant", "Montgomery Bus Boycott", "Nat Turner", "Harriet Tubman", "March on Washington", "Dr. MLK", "Malcolm X", "Ronald McNair", "Mae Jemison", "Thurgood Marshall", "Bloody Sunday", "George Floyd", "Trayvon Martin", "Million Man March"]
        case "Sayings":
            return ["You don't have all the answers sway", "When they go low we go high", "When someone shows you who they are, believe them the first time", "We Didn't land on Plymouth Rock", "You know it's funny when it rains pours", "Don't write a check your ass can't cash", "Love, Peace and Soul", "You don't believe fat meat is greasy", "Oh my Goodness", "Get to stepping", "If that aint the pot calling the kettle black", "Talk to the Hand", "Believe half of what you see", "What's the 411?", "You haven't heard it from me", "Hard head make a soft behind", "Hey, Hey, Hey", "You better check yourself before you wreck yourself"]
        case "Pop Culture":
            return ["Clarence Avant", "Joe Louis", "Kem", "Dave Chappelle", "Kai Cenaat", "Kendrick Lamar", "Quincy Jones", "James Earl Jones Jr.", "Prince", "Lena Horne", "Diahnn Carroll", "Druski", "Phylicia Rashaad Allen", "Debbi Allen", "Whitney Houston", "Coleman A. Young", "Billy Holiday"]
        case "Misc":
            return ["Boyz N The Hood", "Menace to Society", "A different world", "In living color", "Soul Train", "Kareem Abdul Jabbar", "Isiah Zeke Thomas", "Kobe Bryant", "Micheal Jordan", "Earvin Magic Johnson", "New Edition", "Cassius Clay", "Eddie Murphy", "Drake", "Yeezy"]
        default:
            return ["Answer 1", "Answer 2", "Answer 3", "Answer 4", "Answer 5"]
        }
    }
    
    func shortenText(_ text: String) -> String {
        // Shorten text to fit in button, but keep it readable
        if text.count <= 25 {
            return text
        } else {
            // Find a good breaking point (space or punctuation)
            let maxLength = 25
            let truncated = String(text.prefix(maxLength))
            
            // Try to find the last space before the cutoff
            if let lastSpaceIndex = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpaceIndex]) + "..."
            } else {
                return truncated + "..."
            }
        }
    }
    
    func shortenTextForSayings(_ text: String) -> String {
        // Special shortening for sayings - show beginning of phrase
        if text.count <= 60 {
            return text
        } else {
            // Find a good breaking point (space or punctuation)
            let maxLength = 60
            let truncated = String(text.prefix(maxLength))
            
            // Try to find the last space before the cutoff
            if let lastSpaceIndex = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpaceIndex]) + "..."
            } else {
                return truncated + "..."
            }
        }
    }
    
    func showFullTextPopup(_ text: String) {
        print("🎯 POPUP: showFullTextPopup called with text: \(text)")
        print("🎯 POPUP: Current popupText before: \(popupText ?? "nil")")
        print("🎯 POPUP: Current category: \(gameVM.currentCategory)")
        
        // Set the popup text immediately
        popupText = text
        
        print("🎯 POPUP: Current popupText after: \(popupText ?? "nil")")
        print("🎯 POPUP: shouldShowPopup will be: \(shouldShowPopup)")
    }
}


#Preview {
    GuessTheImposter(path: .constant([]))
        .environmentObject(GameViewModel())
}
