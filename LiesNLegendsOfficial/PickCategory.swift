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
    
    func getRandomWord(from category: [String]) -> String {
        return category.randomElement() ?? "No word found"
    }
    
    func startCategory(_ category: [String], name: String) {
        let word = getRandomWord(from: category)
        print("Category picked: \(name), word: \(word), players: \(gameVM.players.map { $0.name })")
        gameVM.pickCategory(name, word: word)
        gameVM.assignRoles()
    }
    
    var body: some View {
            ZStack {
                Color(.background)
                    .ignoresSafeArea(edges: .all)
                VStack {
                    Image("LogoDark")
                        .resizable()
                        .frame(width: 296, height: 80)
                        .padding()
                        .padding()
                    Text("Pick a Category...")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                    NavigationLink(
                        destination: CardFlipView(path: $path).environmentObject(gameVM),
                        label: {
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
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        startCategory(phrases, name: "Sayings")
                    })
                    .padding(10)
                    NavigationLink(
                        destination: CardFlipView(path: $path).environmentObject(gameVM),
                        label: {
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
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        startCategory(motown, name: "Motown")
                    })
                    .padding(10)
                    NavigationLink(
                        destination: CardFlipView(path: $path).environmentObject(gameVM),
                        label: {
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
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        startCategory(historicalFigures, name: "History")
                    })
                    .padding(10)
                    NavigationLink(
                        destination: CardFlipView(path: $path).environmentObject(gameVM),
                        label: {
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
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        startCategory(popCulture, name: "Pop Culture")
                    })
                    .padding(10)
                    NavigationLink(
                        destination: CardFlipView(path: $path).environmentObject(gameVM),
                        label: {
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
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        startCategory(misc, name: "Miscellaneous")
                    })
                    .padding(10)
                }
            }
    }
}


#Preview {
    PickACategory(path: .constant([])).environmentObject(GameViewModel())
}
