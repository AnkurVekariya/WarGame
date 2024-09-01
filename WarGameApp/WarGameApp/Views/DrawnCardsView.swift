//
//  DrawnCardsView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI
import WarGameSDK

struct DrawnCardsView: View {
    
    @State private var cardNames: [String] = [] // Add this for debugging
    @State private var cardValues: [String] = [] // Add this for debugging
    let cards: [Card]
    let playerNames: [String] // Player name to display on each card
    let cardWidth: CGFloat = 80 // Size to fit well within UI
    let cardHeight: CGFloat = 120
    let cardSpacing: CGFloat = 10 // Space between cards
    let nameLabelHeight: CGFloat = 20
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.yellow.opacity(0.2)) // White background for the table
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5) // Shadow for 3D effect
                    .frame(width: geometry.size.width - 20 , height: cardHeight + 50)
                    .padding(.horizontal, 10)
                
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: cardSpacing) {
                            ForEach(Array(cards.enumerated()), id: \.element.code) { index, card in
                                VStack {
                                    CardImageView(cardCode: card.code!)
                                        .scaledToFit()
                                        .frame(width: cardWidth, height: cardHeight)
                                        .padding(2)
                                    
                                    Text(playerNames[index])
                                        .font(.caption)
                                        .foregroundColor(.black)
                                        .padding(4)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .frame(height: nameLabelHeight)
                                }
                            }
                        }
                        .frame(width: geometry.size.width - 20)
                        .padding(.horizontal, 10)

                    }
                    .padding(.horizontal, 0)
                }
            }
            
        }

    }
}
