//
//  WarGameNetworkService.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 02/09/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchDeck(completion: @escaping (Result<Deck, Error>) -> Void)
    func fetchCards(deckId: String, count: Int, completion: @escaping (Result<DrawCardsModel, Error>) -> Void)
}

class WarGameNetworkService: NetworkServiceProtocol {
    
    func fetchDeck(completion: @escaping (Result<Deck, Error>) -> Void) {
        let url = URL(string: "\(Utility.baseUrl)/new/shuffle/")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                let deck = try JSONDecoder().decode(Deck.self, from: data)
                completion(.success(deck))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCards(deckId: String, count: Int, completion: @escaping (Result<DrawCardsModel, Error>) -> Void) {
        let url = URL(string: "\(Utility.baseUrl)/\(deckId)/draw/?count=\(count)")!
            let request = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                    return
                }
                
                do {
                    let cardsResponse = try JSONDecoder().decode(DrawCardsModel.self, from: data)
                    completion(.success(cardsResponse))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func makeShuffleAtFifthWin(deckId: String, PileName: String, completion: @escaping (Result<Deck, Error>) -> Void) {
        let url = URL(string: "\(Utility.baseUrl)/\(deckId)/pile/\(PileName)/return")! ///deck/{deck_id}/pile/{pile_name}
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                let str = String(decoding: data, as: UTF8.self)
                let deck = try JSONDecoder().decode(Deck.self, from: data)
                completion(.success(deck))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}

