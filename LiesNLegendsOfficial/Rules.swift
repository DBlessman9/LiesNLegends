//
//  Rules.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI

struct RulesScreen: View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
           
        VStack {
            ScrollView {
                Image("masks")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)
                    .padding(.top)
                
                Text("Game Rules")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Setup")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("(4-6 Players)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("""
Add each player's name to the game then select a category for the round.
Categories include: Black History, Motown, Celebrities etc.
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Phone Passing Phase")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("(Assign your Role)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("""
Once the category is chosen, the phone will guide you through each player viewing their own private role:

    1    When it's your turn, tap "Flip Card" to see your role and secret word
    2    Keep your role secret! Don't let others see your screen
    3    After viewing, swipe and pass the phone to the next player
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Player Roles")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("(Legitimate or Imposter)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("""
The Imposter: 
One player will be the imposter they won't know what the word is but they have to act like they do.

Legitimates: 
All legitimates get the same word from the category Example: "Diana Ross"
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Giving Clues")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("(Be Strategic)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("""
Once everyone has viewed their card:
    •    Players take turns giving short clues
    •    Clues must be related to your word
    •    Cannot be part of the word itself
    •    Keep it brief one or two words maximum

Example Round: 
Category: Motown Secret 
Word: "Diana Ross"
    •    Player 1 (Legitimate): "Singer"
    •    Player 2 (Legitimate): "Supreme"
    •    Player 3 (Imposter): "Music" (only knows "Motown")
    •    Player 4 (Legitimate): "Detroit"
    •    Player 5 (Legitimate): "Diva"

Notice how the Imposter's clue "Music" is more generic!
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Voting Phase")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("(Good Luck!)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("""
After everyone gives one clue pass the phone around for voting:

For Legitimates:
    •    Each Legitimate privately votes for who they think the imposter is
    •    Keep votes secret until everyone has voted

For the Imposter:
    •    Gets multiple choice options to guess what they think the secret word is based on all the clues they heard during the round
    •    This is their chance to win points by figuring out the word
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Scoring")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("""
Legitimates Win: 
For correctly identifying the imposter you earn 1 point.

Imposter Wins: 
If the imposter avoids detection, they earn a point. The imposter also earns a point by correctly guessing the secret word from multiple choice options

Disqualification: 
If a player exposes the word or phrase, then press the "Disqualify" button while their card is present in view to end the round, awarding the other players a point each.
""")
                .foregroundColor(.white)
                .padding()
                
                Text("Tips for Success")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("""
For Legitimates:
    •    Don't be too obvious!
    •    Pay attention to vague or generic clues...typically from the imposter

For the Imposter:
    •    Listen carefully to all clues to figure out the word
    •    Give clues that could apply to multiple things in the category
    •    Try to blend in with the group's clue giving style
    •    Pay close attention...you'll need to guess the word at the end!
""")
                .foregroundColor(.white)
                .padding()
                
                Text("End of Round")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("""
    •    View the results and see how many points you've earned!
    •    Start a new round with a different category
    •    Play as many rounds as you'd like!
    •    The player with the most points after all rounds wins the game!
""")
                .foregroundColor(.white)
                .padding()
            }
            .multilineTextAlignment(.leading)
    
        }
      }
   
    }
}

#Preview {
    RulesScreen()
}
