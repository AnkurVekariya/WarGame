//
//  ContentView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 31/08/24.
//

import SwiftUI
import WarGameSDK
import Foundation


struct StackedCardView: View {
    let cards: [Card]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ForEach(cards) { card in
                CardImageView(cardCode: card.code!)
                    .frame(width: 100, height: 150)
                    .offset(x: CGFloat(cards.firstIndex(of: card) ?? 0) * 15,
                            y: CGFloat(cards.firstIndex(of: card) ?? 0) * 0)
            }
        }
    }
}

struct PlayerPilesView: View {
    let players: [Player]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(players) { player in
                        VStack(alignment: .leading) {
                            Text(player.name)
                                .font(.title2)
                                .padding(.bottom, 2)

                            if let pile = player.pile, !pile.isEmpty {
                                StackedCardView(cards: pile)
                                    .frame(width: geometry.size.width * 0.8, height: min(300, geometry.size.height * 0.3))
                            } else {
                                Text("No cards")
                                    .foregroundColor(.gray)
                                    .padding(.top, 2)
                            }

                            Text("Wins: \(player.battlesWon)")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct PlayerSelectionView: View {
    @Binding var numberOfPlayers: Int
    var onStartGame: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Number of Players: ")
                Picker("Number of Players", selection: $numberOfPlayers) {
                    ForEach(2..<5) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            Button("Start Game", action: onStartGame)
                .padding()
        }
    }
}

struct DrawnCardsView: View {
    let cards: [Card]

    var body: some View {
        VStack {
            Text("Drawn Cards")
                .font(.headline)
                .padding()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(cards, id: \.code) { card in
                        CardImageView(cardCode: card.code!)
                            .frame(width: 100, height: 150)
                            .padding(2)
                    }
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = WarGame()
    @State private var numberOfPlayers: Int = 2
    @State private var showPlayerSelection = true

    var body: some View {
        GeometryReader { geometry in
            VStack {
                PlayerSelectionView(numberOfPlayers: $numberOfPlayers, onStartGame: {
                    viewModel.startNewGame(withNumberOfPlayers: numberOfPlayers)
                    showPlayerSelection = false
                })
            }
        }
    }
}





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
    }
}




class CardImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var imageCache = NSCache<NSString, UIImage>()

    func loadImage(for cardCode: String) {
        if let cachedImage = imageCache.object(forKey: cardCode as NSString) {
            self.image = cachedImage
            return
        }

        let url = URL(string: "https://deckofcardsapi.com/static/img/\(cardCode).png")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
                self.imageCache.setObject(image, forKey: cardCode as NSString)
            }
        }.resume()
    }
}


