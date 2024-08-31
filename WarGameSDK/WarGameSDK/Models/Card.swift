//
//  Card.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation

public struct Card: Identifiable, Decodable, Equatable {
    public var id = UUID()
    public let code: String?
    public let image: String?
    public let images: Images?
    public let suit: String?
    public let value: String
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.code == rhs.code
    }

    public enum CodingKeys: String, CodingKey {
        case code
        case image
        case images
        case suit
        case value
    }
}

public struct Images: Decodable {
    public let png: String
    public let svg: String

    public init(png: String, svg: String) {
        self.png = png
        self.svg = svg
    }
}
