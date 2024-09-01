//
//  PlayerSelectionView.swift
//  WarGameApp
//
//  Created by Ankur Vekaria on 01/09/24.
//

import Foundation
import SwiftUI
import WarGameSDK

struct PlayerSelectionView: View {
    @Binding var numberOfPlayers: Int
    var onStartGame: () -> Void

    var body: some View {
        VStack {
            VStack {
                Text("Select number of Players: ")
                   .font(.headline) // Set font to headline
                   .fontWeight(.bold) // Make text bold
                   .foregroundColor(.white) // Set text color to white

                ZStack {
                    Color.gray // Background color for the picker
                        .cornerRadius(8) // Round corners of the background
                        .frame(height: 30) // Adjust height to fit the picker
                    
                    Picker("Number of Players", selection: $numberOfPlayers) {
                        ForEach(2..<5) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal) // Add horizontal padding to the picker container
            }
           
            Button(action: onStartGame) {
                Text("Start Game")
                    .font(.subheadline) // Larger font size for the button text
                    .fontWeight(.bold) // Make text bold
                    .foregroundColor(.white) // White text color
                    .padding() // Padding inside the button
                    .background(Color.darkYellow) // Golden background color
                    .cornerRadius(15) // Corner radius for rounded corners
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5) // Shadow for a slight 3D effect
            }
            .padding(.top, 50) // Add padding around the button
        }
    }
}
