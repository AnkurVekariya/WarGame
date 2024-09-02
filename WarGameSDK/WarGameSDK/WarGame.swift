//
//  WarGame.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation
import Combine

public class WarGame: ObservableObject {
    
    @Published public var players: [Player] = []
    @Published public var deckId: String = ""
    @Published public var drawnCards: [Card] = []
    @Published public var alertMessage = ""
    @Published public var showAlert = false
    @Published public var currentRoundWinner: String = ""
    @Published public var isGameStarted = false
    
    public var deck: Deck?
    
    private var numberOfPlayers: Int = 2
    
    public init() {}
    
    public func startGame(withNumberOfPlayers numberOfPlayers: Int) {
        guard numberOfPlayers > 0 && numberOfPlayers <= 4 else { return }

        let url = URL(string: "\(Utility.baseUrl)/new/shuffle/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                self.deck = try JSONDecoder().decode(Deck.self, from: data)
                self.deckId = self.deck?.deck_id ?? ""
                
                DispatchQueue.main.async {
                    self.dealCards(to: numberOfPlayers)
                }
                
            } catch {
                print("Failed to decode deck: \(error)")
            }
        }
        task.resume()
    }
    
    public func playRound() {
        print("play round func called")
        guard players.count > 1 else { return }

        let drawnCards = players.compactMap { player -> (Player, Card)? in
            guard let pile = player.pile, !pile.isEmpty else { return nil }
            let card = pile.randomElement()!
            return (player, card)
        }

        self.drawnCards = drawnCards.map { $0.1 }

        let winner = determineRoundWinner(drawnCards: drawnCards)
        updatePlayerPiles(with: drawnCards, winner: winner)
        if let winningPlayer = players.first(where: { $0.battlesWon >= 10 }) {
            DispatchQueue.main.async {
                self.alertMessage = "\(winningPlayer.name) wins the game!"
                self.showAlert = true
            }
        } else {
            DispatchQueue.main.async {
                self.currentRoundWinner = winner.name
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.drawnCards = []
                }
            }
        }
    }
    
    public func restartGame() {
        self.players = []
        self.drawnCards = []
        self.currentRoundWinner = ""
        self.deckId = ""
        self.isGameStarted = false
        self.showAlert = false
        self.alertMessage = ""
        self.numberOfPlayers = 2
    }

    public func startNewGame(withNumberOfPlayers numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        startGame(withNumberOfPlayers: numberOfPlayers)
    }
}

extension WarGame {
    
    private func dealCards(to numberOfPlayers: Int) {
        
        guard let deckId = deck?.deck_id else { return }

        let url = URL(string: "\(Utility.baseUrl)/\(deckId)/draw/?count=\(numberOfPlayers * 52)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let cardsResponse = try JSONDecoder().decode(DrawCardsModel.self, from: data)
                guard let cards = cardsResponse.cards else {
                    return
                }
                let dealtCards = Array(cards.prefix(numberOfPlayers * 52))
                let cardChunks = dealtCards.chunked(into: dealtCards.count / numberOfPlayers)

                DispatchQueue.main.async {
                    self.players = cardChunks.prefix(numberOfPlayers).enumerated().map { index, cards in
                        Player(name: "Player \(index + 1)", pile: cards)
                    }
                    self.isGameStarted = true
                }
            } catch {
                print("Failed to decode cards: \(error)")
            }
        }
        task.resume()
    }
    
    private func determineRoundWinner(drawnCards: [(Player, Card)]) -> Player {
        // Ensure there are cards drawn
        guard !drawnCards.isEmpty else {
            fatalError("No cards were drawn")
        }
        
        // Find the highest card value
        guard let highestCardValue = drawnCards.map({ $0.1.numericValue }).max() else {
               fatalError("Failed to determine the highest card value")
           }
        
        print("highestCardValue == \(highestCardValue)")
        
        // Filter players with the highest card value
        let highestCardPlayers = drawnCards.filter { $0.1.numericValue == highestCardValue }
            
        
        // If there is only one player with the highest card value, return that player
        if highestCardPlayers.count == 1 {
            return highestCardPlayers.first!.0
        }
        
        // If there are multiple players with the highest card value, choose the one with the most remaining cards in their pile
        let playerWithMostCards = highestCardPlayers.max(by: { ($0.0.pile?.count ?? 0) < ($1.0.pile?.count ?? 0) })
        
        // If there is a single player with the maximum count of cards, return that player
        if let playerWithMostCards = playerWithMostCards, highestCardPlayers.filter({ $0.0.pile?.count == playerWithMostCards.0.pile?.count }).count == 1 {
            return playerWithMostCards.0
        }
        
        // If still tied, return a random player from those with the highest card value
        return highestCardPlayers.randomElement()!.0
    }

    
    private func updatePlayerPiles(with drawnCards: [(Player, Card)], winner: Player) {
        let winningCards = drawnCards.map { $0.1 }
        if let index = players.firstIndex(where: { $0.id == winner.id }) {
            DispatchQueue.main.async {
                self.players[index].pile?.append(contentsOf: winningCards)
                self.players[index].battlesWon += 1
            }
        }

        for (player, card) in drawnCards {
            if let index = players.firstIndex(where: { $0.id == player.id }) {
               DispatchQueue.main.async {
                   self.removeCardFromPlayerPile(playerIndex: index, cardCode: card.code!)
               }
            }
        }
    }
    
    func removeCardFromPlayerPile(playerIndex: Int, cardCode: String) {
        guard playerIndex >= 0 && playerIndex < players.count else {
            return
        }
        
        // Find the index of the first occurrence of the card to remove
        if let cardIndex = players[playerIndex].pile?.firstIndex(where: { $0.code == cardCode }) {
            players[playerIndex].pile?.remove(at: cardIndex)
        }
    }
}
