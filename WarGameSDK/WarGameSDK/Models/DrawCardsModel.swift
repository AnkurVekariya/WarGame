//
//  DrawCardsModel.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation

public struct DrawCardsModel: Decodable {
    public let cards: [Card]?
    public let deck_id : String?
    public let remaining : Int?
    public let success : Bool?
    
    public enum CodingKeys: String, CodingKey {
        case cards = "cards"
        case deck_id = "deck_id"
        case remaining = "remaining"
        case success = "success"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cards = try values.decodeIfPresent([Card].self, forKey: .cards)
        deck_id = try values.decodeIfPresent(String.self, forKey: .deck_id)
        remaining = try values.decodeIfPresent(Int.self, forKey: .remaining)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
    }

}

