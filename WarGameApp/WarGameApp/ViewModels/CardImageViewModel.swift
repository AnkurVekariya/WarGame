//
//  CardImageViewModel.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import UIKit

class CardImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var imageCache = NSCache<NSString, UIImage>()

    func loadImage(for cardCode: String) {
        if let cachedImage = imageCache.object(forKey: cardCode as NSString) {
            self.image = cachedImage
            return
        }

        let url = URL(string: "https://deckofcardsapi.com/static/img/\(cardCode).png")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
                self.imageCache.setObject(image, forKey: cardCode as NSString)
            }
        }.resume()
    }
}
