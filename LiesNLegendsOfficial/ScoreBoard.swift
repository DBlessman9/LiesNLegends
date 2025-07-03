//
//  ScoreBoard.swift
//  LiesNLegendsOfficial
//
//  Created by Derald Blessman on 2/25/25.
//

import SwiftUI

struct ScoreBoard: View {
    @Binding var path: [AppRoute]
    
    var players: [Player] = []
    
    var state = GameState.setup
    var doesHighestScoreWin = true
    
    var winners: [Player] {
        guard state == .gameOver else { return [] }
        
        var winningScore = 0
        if doesHighestScoreWin {
            winningScore = Int.min
            for player in players {
                winningScore = max(player.score, winningScore)
            }
        } else {
            winningScore = Int.max
            for player in players {
                winningScore = min(player.score, winningScore)
            }
        }
        
        return players.filter { player in
            player.score == winningScore
        }
    }
    
    mutating func resetScores (to newValue: Int) {
        for index in 0..<players.count {
            players[index].score = newValue
        }
    }
    
    var body: some View {
        List(players) { player in
            HStack {
//                    if player.isTurn {
//                        Image(systemName: "play.fill")
//                    }
                Text("Player \(player.id)")
                Spacer()
                Text(player.name)
                    .bold(player.isTurn)
                Spacer()
                Text("\(player.score)")
                
            }
        }
    }
}


