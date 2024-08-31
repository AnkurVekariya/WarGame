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
    
    public var deck: Deck?
    
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
            } catch {
                print("Failed to decode deck: \(error)")
            }
        }
        task.resume()
    }
    
    public func playRound() {
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
            }
        }
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
                }
            } catch {
                print("Failed to decode cards: \(error)")
            }
        }
        task.resume()
    }
    
    private func determineRoundWinner(drawnCards: [(Player, Card)]) -> Player {
        let highestCard = drawnCards.max { $0.1.value < $1.1.value }!
        let highestCardPlayer = drawnCards.filter { $0.1.value == highestCard.1.value }

        if highestCardPlayer.count == 1 {
            return highestCardPlayer.first!.0
        }

        let playerWithMostCards = highestCardPlayer.max { $0.0.pile?.count ?? 0 < $1.0.pile?.count ?? 1 }!
        if highestCardPlayer.filter({ $0.0.pile?.count == playerWithMostCards.0.pile?.count }).count == 1 {
            return playerWithMostCards.0
        }

        return highestCardPlayer.randomElement()!.0
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
                    self.players[index].pile?.removeAll { $0.code == card.code }
                }
            }
        }
    }
}
