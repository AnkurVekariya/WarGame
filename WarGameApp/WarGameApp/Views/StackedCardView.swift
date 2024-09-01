//
//  StackedCardView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI
import WarGameSDK

struct StackedCardView: View {
    let cards: [Card]
    let cardWidth: CGFloat = 100
    let cardHeight: CGFloat = 150

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ForEach(cards.indices, id: \.self) { index in
                CardImageView(cardCode: cards[index].code!)
                    .frame(width: cardWidth, height: cardHeight)
                    .offset(x: CGFloat(index) * 10, y: CGFloat(index) * 5) // Adjust to create a bundled look
                    .opacity(index == cards.count - 1 ? 1 : 0.8) // Show top card fully opaque
            }
        }
    }
}
