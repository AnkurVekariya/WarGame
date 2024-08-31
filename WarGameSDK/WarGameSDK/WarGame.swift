//
//  WarGame.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation
import Combine

public class WarGame: ObservableObject {
    
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
