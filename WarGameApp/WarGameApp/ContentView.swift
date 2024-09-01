//
//  ContentView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 31/08/24.
//

import SwiftUI
import WarGameSDK
import Foundation

struct PlaceholderImageView: View {
    let playerName: String
    let wins: Int
    let imageSize: CGSize = CGSize(width: 100, height: 150)

    var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                Image(systemName: "card.fill") // Placeholder image (use a system image or a custom image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .background(Color.gray.opacity(0.2)) // Background color for image
                    .cornerRadius(10)
                    .shadow(radius: 10, x: 0, y: 5) // Shadow for the placeholder image

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
                }
                .padding([.leading, .bottom], 10)
            }
        }
    }
}

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

struct PlayerPilesView: View {
    let players: [Player]
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Define 2-column grid

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(players) { player in
                        VStack(alignment: .leading) {
                            PlaceholderImageView(playerName: player.name, wins: player.battlesWon)
                                .frame(width: (geometry.size.width / 2) - 20, height: min(300, geometry.size.height * 0.3))
                                .padding(.bottom, 10)

                            // Removed redundant "Wins" label here as it's now part of the card placeholder
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
            VStack {
                Text("Select number of Players: ")
                   .font(.headline) // Set font to headline
                   .fontWeight(.bold) // Make text bold
                   .foregroundColor(.white) // Set text color to white

                ZStack {
                    Color.gray // Background color for the picker
                        .cornerRadius(8) // Round corners of the background
                        .frame(height: 30) // Adjust height to fit the picker
                    
                    Picker("Number of Players", selection: $numberOfPlayers) {
                        ForEach(2..<5) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal) // Add horizontal padding to the picker container
            }
//            .padding()
           
            
            Button(action: onStartGame) {
                Text("Start Game")
                    .font(.subheadline) // Larger font size for the button text
                    .fontWeight(.bold) // Make text bold
                    .foregroundColor(.white) // White text color
                    .padding() // Padding inside the button
                    .background(Color(red: 0.8, green: 0.6, blue: 0.0)) // Golden background color
                    .cornerRadius(15) // Corner radius for rounded corners
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5) // Shadow for a slight 3D effect
            }
            .padding(.top, 50) // Add padding around the button
        }
    }
}

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
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(cards.indices, id: \.self) { index in
                        let card = cards[index]
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
                .frame(width: totalWidth) // Set the frame width based on total width of cards
                .padding(.horizontal, (UIScreen.main.bounds.width - totalWidth) / 2) // Center horizontally
            }
            .padding()
            .onChange(of: cards) { newValue in
                            cardNames = newValue.map { $0.code! } // Debugging line to see updates
                            cardValues = newValue.map { $0.value }
                            print("Cards updated: \(cardNames)")
                            print("Cards Values: \(cardValues)")
                        }
        }
    }

    private var totalWidth: CGFloat {
        CGFloat(cards.count) * (cardWidth + cardSpacing) - cardSpacing
    }
}

struct ContentView: View {
    @StateObject private var viewModel = WarGame()
    @State private var numberOfPlayers: Int = 2
    @State private var showPlayerSelection = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.0, green: 0.39, blue: 0.0)
                    .ignoresSafeArea()  // Background color for the entire GeometryReader
            VStack {
                if viewModel.isGameStarted {
                    VStack {
                        Button("Play Round") {
                            viewModel.playRound()
                        }
                        .padding()
                        
                        Text("Current Round Winner: \(viewModel.currentRoundWinner)")
                            .padding()
                        
                        // Display drawn cards with the name of the player who drew each card
                        if !viewModel.drawnCards.isEmpty {
                            // Generate an array of player names for the drawn cards
                            let playerNames = viewModel.drawnCards.indices.map { index in
                                viewModel.players[index % viewModel.players.count].name
                            }
                            DrawnCardsView(cards: viewModel.drawnCards, playerNames: playerNames)
                                .frame(width: geometry.size.width, height: 150) // Adjust height if needed
                        }
                        
                        // Display player piles with overlapping cards
                        Text("Player Piles")
                            .font(.headline)
                            .padding()
                        PlayerPilesView(players: viewModel.players)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    }
                } else if showPlayerSelection {
                    Spacer()
                    PlayerSelectionView(numberOfPlayers: $numberOfPlayers, onStartGame: {
                        viewModel.startNewGame(withNumberOfPlayers: numberOfPlayers)
                        showPlayerSelection = false
                    })
                    Spacer()
                } else {
                    Button("Restart Game") {
                        viewModel.restartGame()
                        showPlayerSelection = true
                    }
                    .padding()
                }
            }
        }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Game Over"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("Restart")) {
                        viewModel.restartGame()
                        showPlayerSelection = true
                    }
                )
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
        .onChange(of: cardCode) { newCode in
            loader.loadImage(for: newCode)
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


