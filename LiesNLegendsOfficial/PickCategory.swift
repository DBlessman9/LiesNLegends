//
//  PickCategory.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI


struct GuessItem {
    let name: String
    let hints: [String]
}



var motown: [String] = ["David Ruffin", "Aretha Franklin", "Marvin Gaye", "Smokey Robinson (HC)", "Rick James", "Prince (HC)", "Martha Reeves", "Diana Ross", "Jackson 5", "Berry Gordy", "Stevie Wonder", "The Temptations", "The Isley Brothers", "The Miracles", "Al Green"]

var historicalFigures: [String] = ["Garret Morgan", "Madame CJ Walker", "Mary Ellen Pleasant", "Montgomery Bus Boycott (HC)", "Nat Turner", "Harriet Tubman", "March on Washington", "Dr. MLK", "Malcolm X", "Ronald McNair", "Mae Jemison", "Thurgood Marshall", "Bloody Sunday", "George Floyd", "Trayvon Martin", "Million Man March"]

var phrases: [String] = ["You don't have all the answers sway..— Kanye West", "When they go low we go high…—Michelle Obama", "When someone shows you who they are, believe them the first time.—Maya Angelou", "We Didn't land on Plymouth Rock, my brothers and sisters-Plymouth Rock landed on us-Malcolm X", "You know it's funny when it rains pours, They got money for wars, but can feed the poor-Tupac Shakur", "Don't write a check your ass- can't cash! -Black Mom", "Love, Peace and Soul - Don Cornelius host of Soul Train", "You don't believe fat meat is greasy-Black Mom", "Oh my Goodness… Oh my Goodness -SheNa-Na (character from Martin)", "Get to stepping- Martin (main character from Martin)", "If that aint the pot calling the kettle black -Black Household", "Talk to the Hand….cause you don't understand-ShaNaNa (Character from Martin)", "Believe half of what you see. Some and none of what your hear -Marvin Gaye", "What's the 411? -Mary J. Blige", "You haven't heard it from me, cause I aint the one to gossip- Benita Betrayal (in Living Color)", "Hard head make a soft behind- Black Grandparent", "Hey, Hey, Hey- Fat Albert (Cosby Kids)", "You better check yourself before you wreck yourself- Black Parents"]

var popCulture: [String] = ["Clarence Avant", "Joe Louis", "Kem", "Dave Chappelle", "Kai Cenaat", "Kendrick Lamar", "Quincy Jones", "James Earl Jones Jr.", "Prince", "Lena Horne", "Diahnn Carroll (Black Actress)", "Druski", "Phylicia Rashaad Allen", "Debbi Allen", "Whitney Houston", "Coleman A. Young", "Billy Holiday"]

var misc: [String] = ["Boyz N The Hood", "Menace to Society", "A different world", "In living color", "Soul Train", "Kareem Abdul Jabbar", "Isiah \"Zeke\" Thomas", "Kobe Bryant", "Micheal Jordan", "Earvin \"Magic\" Johnson", "New Edition", "Cassius Clay", "Eddie Murphy", "Drake", "Yeezy"]

var categories = [motown, historicalFigures, phrases, popCulture, misc]

struct PickACategory: View {
    @Binding var path: [AppRoute]
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var soundManager: SoundManager
    
    func getRandomWord(from category: [String]) -> String {
        return category.randomElement() ?? "No word found"
    }
    
        func startCategory(_ category: [String], name: String) {
        // Don't increment round here - this starts the round, doesn't complete it
        // Round will be incremented when the round is actually completed
        print("🔄 Starting round: Round \(gameVM.currentRound)")
        
        let word = getRandomWord(from: category)
        print("Category picked: \(name), word: \(word), players: \(gameVM.players.map { $0.name })")
        gameVM.pickCategory(name, word: word)
        gameVM.assignRoles()

        // Initialize player selections for the new round
        for player in gameVM.players {
            gameVM.playerSelections[player] = nil
        }
        gameVM.imposterAnswers.removeAll()

        // Navigate to card flip view
        path.append(.cardFlip)
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
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    
                    Image("LogoDark")
                        .resizable()
                        .frame(width: 296, height: 80)
                        .padding()
                        .padding()
                    
                    // Show round and score information
                    VStack(spacing: 10) {
                        Text("Round \(gameVM.currentRound)")
                            .font(.title)
                            .foregroundColor(.green)
                            .bold()
                        
                        // Always show scores, starting from Round 1
                        Text("Current Scores:")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(gameVM.players) { player in
                                    VStack {
                                        Text(player.name)
                                            .font(.caption)
                                            .bold()
                                        Text("\(player.score)")
                                            .font(.title3)
                                            .foregroundColor(.green)
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.9))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Text("Pick a Category...")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .padding(.top, 5)
                        .padding(.bottom, 20)
                    
                    Button {
                        startCategory(phrases, name: "Sayings")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.black)
                                .cornerRadius(50)
                            Text("SAYINGS")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                    
                    Button {
                        startCategory(motown, name: "Motown")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.black)
                                .cornerRadius(50)
                            Text("MOTOWN")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                    
                    Button {
                        startCategory(historicalFigures, name: "History")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.black)
                                .cornerRadius(50)
                            Text("HISTORY")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                    
                    Button {
                        startCategory(popCulture, name: "Pop Culture")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.black)
                                .cornerRadius(50)
                            Text("POP CULTURE")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                    
                    Button {
                        startCategory(misc, name: "Miscellaneous")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 6)
                                .font(.headline)
                                .frame(width: 200, height: 40)
                                .background(Color.black)
                                .cornerRadius(50)
                            Text("MISCELLANEOUS")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    PickACategory(path: .constant([])).environmentObject(GameViewModel())
}
