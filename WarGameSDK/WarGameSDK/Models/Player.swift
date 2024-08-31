//
//  Player.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation

public struct Player: Identifiable {
    public let id = UUID()
    public var name: String
    public var pile: [Card]?
    public var battlesWon: Int = 0

    public init(name: String, pile: [Card]?, battlesWon: Int = 0) {
        self.name = name
        self.pile = pile
        self.battlesWon = battlesWon
    }
}
