//
//  PlaceholderImageView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI
import WarGameSDK

struct PlaceholderImageView: View {
    let playerName: String
    let wins: Int
    let imageSize: CGSize = CGSize(width: 100, height: 150)
    let cards: [Card]

    var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                // Create a ZStack for the 3D effect
                ForEach(0..<5) { index in
                    Image(systemName: "card.fill") // Placeholder image
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)]),
                                                   startPoint: .top, endPoint: .bottom))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 5, y: 5) // Black shadow for depth
                        .rotation3DEffect(
                            .degrees(Double(index) * 2), // Rotate slightly for the bundle effect
                            axis: (x: 1, y: 0, z: 0),
                            perspective: 0.5
                        )
                        .offset(x: CGFloat(index * -5), y: CGFloat(index * 2)) // Offset each card to create the bundle effect
                }

                VStack(alignment: .leading) {
                    Text(playerName)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue.opacity(0.7)) // Background color for player name
                        .cornerRadius(5)
                        .shadow(radius: 3, x: 1, y: 1) // Shadow for name label

                    Text("Wins: \(wins)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red.opacity(0.7)) // Background color for wins label
                        .cornerRadius(5)
                        .shadow(radius: 3, x: 1, y: 1) // Shadow for wins label
                    
                    VStack(spacing: 2) { // Stack two lines of text with a small space
                        Text("Cards")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                        Text("\(cards.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                     }
                    .padding(.top, 5)
                           .background(Color.yellow)
                           .clipShape(Circle())
                           .foregroundColor(.black)
                           .shadow(radius: 3, x: 1, y: 1) // Shadow for badge
                           .padding([.trailing, .top], 10)
                }
                           
            }
        }
    }
}
