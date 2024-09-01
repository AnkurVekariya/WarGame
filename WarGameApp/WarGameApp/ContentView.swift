//
//  ContentView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 31/08/24.
//

import SwiftUI
import WarGameSDK
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = WarGame()
    @State private var numberOfPlayers: Int = 2
    @State private var showPlayerSelection = true
    @State private var showWinnerMessage: Bool = false
    @State private var isPlayRoundButtonEnabled = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.0, green: 0.39, blue: 0.0)
                    .ignoresSafeArea()  // Background color for the entire GeometryReader
            VStack {
                if viewModel.isGameStarted {
                    VStack {
                        HStack {
                            Button(action: {
                                viewModel.restartGame()
                                showPlayerSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise") // Restart icon
                                        .foregroundColor(.black) // Black color for the icon
                                        .bold()
                                }
                                .padding()
                                .background(Color.darkYellow) // Golden background color
                                .cornerRadius(10) // Rounded corners
                            }
                            .padding()
                            Spacer()
                            
                        }

                        // Display drawn cards with the name of the player who drew each card
                        // Generate an array of player names for the drawn cards
                        let playerNames = viewModel.drawnCards.indices.map { index in
                            viewModel.players[index % viewModel.players.count].name
                        }
                        DrawnCardsView(cards: viewModel.drawnCards, playerNames: playerNames)
                            .frame(width: geometry.size.width, height: 150) // Adjust height if needed
                            .padding(.top, 10)

                        Spacer().frame(height: 50)
                        if showWinnerMessage {
                            Text("\(viewModel.currentRoundWinner) wins !! ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 2)
                                           
                        }
                        
                        VStack {
                            
                            Button("Play Round") {
                                // Disable the button
                                isPlayRoundButtonEnabled = false
                                
                                viewModel.playRound()
                                
                                showWinnerMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showWinnerMessage = false
                                }
                                
                                // Re-enable the button after 2.5 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    isPlayRoundButtonEnabled = true
                                }
                            }
                            .padding()
                            .background(isPlayRoundButtonEnabled ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .disabled(!isPlayRoundButtonEnabled)
                            .cornerRadius(10)
                            
                        }
                        .padding(.top)

                        
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
                }
                else {
                    ProgressView()
                       .progressViewStyle(CircularProgressViewStyle())
                       .tint(Color.white)
                       .scaleEffect(1.5) // Adjust the size of the spinner
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
