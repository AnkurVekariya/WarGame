//
//  Deck.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation

public struct Deck: Decodable {
    public let deck_id: String
    public let remaining: Int
    public let success: Bool

    public init(deck_id: String, remaining: Int, success: Bool) {
        self.deck_id = deck_id
        self.remaining = remaining
        self.success = success
    }
}
