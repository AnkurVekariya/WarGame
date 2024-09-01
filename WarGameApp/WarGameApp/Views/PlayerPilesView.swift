//
//  PlayerPilesView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI
import WarGameSDK

struct PlayerPilesView: View {
    let players: [Player]
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Define 2-column grid
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: players.count == 2 ? 50 : 30) // Pushes content to the bottom
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(players) { player in
                            
                            if let pile = player.pile, !pile.isEmpty {
                                VStack(alignment: .leading) {
                                    PlaceholderImageView(playerName: player.name, wins: player.battlesWon, cards: pile)
                                        .frame(width: 10, height: 150)
                                        .padding(.bottom, 10)

                                }
                            } else {
                                Text("No cards")
                                    .foregroundColor(.gray)
                                    .padding(.top, 2)
                            }
                            
               
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
