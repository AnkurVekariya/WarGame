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
    
    let networkService = WarGameNetworkService()
    
    public init() {}
    
    func startGame(withNumberOfPlayers numberOfPlayers: Int, completion: @escaping (Result<Void, Error>) -> Void) {
            guard numberOfPlayers > 1 && numberOfPlayers <= 4 else {
                let error = NSError(domain: "GameServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid number of players"])
                completion(.failure(error))
                return
            }
        
            
        self.networkService.fetchDeck { [weak self] result in
                switch result {
                case .success(let deck):
                    self?.deck = deck
                    self?.deckId = deck.deck_id
                    
                    DispatchQueue.main.async {
                        self?.dealCards(to: numberOfPlayers, completion: { result in
                            switch result {
                            case .success():
                                completion(.success(()))
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self?.alertMessage = "\(error)"
                                    self?.showAlert = true
                                }
                            }
                        })
                        
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
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
        startGame(withNumberOfPlayers: numberOfPlayers, completion: { result in
            switch result {
            case .success():
                break;
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alertMessage = "\(error)"
                    self.showAlert = true
                }
            }
        })
    }
}

extension WarGame {
    
    private func dealCards(to numberOfPlayers: Int, completion: @escaping (Result<Void, Error>) -> Void) {
           guard let deckId = deck?.deck_id else {
               let error = NSError(domain: "GameServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deck ID is missing"])
               completion(.failure(error))
               return
           }
           
           let cardCount = numberOfPlayers * 52
           
        self.networkService.fetchCards(deckId: deckId, count: cardCount) { [weak self] result in
               switch result {
               case .success(let cardsResponse):
                   guard let cards = cardsResponse.cards else {
                       let error = NSError(domain: "GameServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No cards in response"])
                       completion(.failure(error))
                       return
                   }
                   
                   let dealtCards = Array(cards.prefix(cardCount))
                   let cardChunks = dealtCards.chunked(into: dealtCards.count / numberOfPlayers)
                   
                   DispatchQueue.main.async {
                       self?.players = cardChunks.prefix(numberOfPlayers).enumerated().map { index, cards in
                           Player(name: "Player \(index + 1)", pile: cards)
                       }
                       self?.isGameStarted = true
                       completion(.success(()))
                   }
                   
               case .failure(let error):
                   DispatchQueue.main.async {
                       completion(.failure(error))
                   }
               }
           }
       }
    
    public func determineRoundWinner(drawnCards: [(Player, Card)]) -> Player {
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
            DispatchQueue.main.async {
                self.players[playerIndex].pile?.remove(at: cardIndex)
            }
           
        }
    }
}
