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
}
