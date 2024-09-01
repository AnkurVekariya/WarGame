//
//  CardImageView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI

struct CardImageView: View {
    @StateObject private var loader = CardImageLoader()
    var cardCode: String
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .onAppear {
                        loader.loadImage(for: cardCode)
                    }
            }
        }
        .onChange(of: cardCode) { newCode in
            loader.loadImage(for: newCode)
        }
    }
}
