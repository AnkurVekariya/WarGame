//
//  Extensions.swift
//  WarGameSDK
//
//  Created by Ankur Vekaria on 31/08/24.
//

import Foundation

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        
        guard size > 0 else { return [] }
        var result: [[Element]] = []
        var currentChunk: [Element] = []
        
        for element in self {
            if currentChunk.count < size {
                currentChunk.append(element)
            } else {
                result.append(currentChunk)
                currentChunk = [element]
            }
        }
        
        if !currentChunk.isEmpty {
            result.append(currentChunk)
        }
        
        return result
    }
}
