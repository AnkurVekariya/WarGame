//
//  WarGameSDKTests.swift
//  WarGameSDKTests
//
//  Created by Ankur Vekaria on 31/08/24.
//

import XCTest
import Combine
@testable import WarGameSDK

class MockURLSessionDataTask: URLSessionDataTask {
    override init() { }
    override func resume() {
        // Simulate network task execution
    }
}

// Mock URLSession to simulate network responses
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // Call the completion handler with the mock data, response, and error
        completionHandler(mockData, mockResponse, mockError)
        // Return a custom data task (MockURLSessionDataTask)
        return MockURLSessionDataTask()
    }
}


final class WarGameSDKTests: XCTestCase {
    
       var viewModel: WarGame!
       var mockSession: MockURLSession!
       var cancellables: Set<AnyCancellable> = []

       override func setUp() {
           super.setUp()
           mockSession = MockURLSession()
           viewModel = WarGame()
       }
    
    // Define your mock cards
       func createMockCard(code: String, image: String?, suit: String?, value: String) -> Card {
           return Card(
               code: code,
               image: image,
               images: nil,
               suit: suit,
               value: value
           )
       }

       override func tearDown() {
           viewModel = nil
           mockSession = nil
           cancellables = []
           super.tearDown()
       }

       func testStartGameSuccessfully() {
           // Arrange
           let mockDeckResponse = "{\"deck_id\": \"testDeckId\"}".data(using: .utf8)
           mockSession.mockData = mockDeckResponse

           let mockCardsResponse = """
           {
               "cards": [
                   {"code": "AS", "value": 14},
                   {"code": "KH", "value": 13}
                   // Add more cards as needed
               ]
           }
           """.data(using: .utf8)
           mockSession.mockData = mockCardsResponse

           viewModel.startGame(withNumberOfPlayers: 2, completion: {result in
           })

           // Act
           let expectation = XCTestExpectation(description: "Game should start and deal cards")
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               // Assert
               XCTAssertTrue(self.viewModel.isGameStarted, "Game should be started")
               XCTAssertEqual(self.viewModel.players.count, 2, "Should have 2 players")
               XCTAssertEqual(self.viewModel.players[0].pile?.count, 26, "Player should have cards")
               XCTAssertEqual(self.viewModel.players[1].pile?.count, 26, "Player should have cards")
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 5.0)
       }

       func testPlayRound() {
           
           // Arrange
           viewModel.players = [
               Player(name: "Player 1", pile: [Card(code: "AS", image: nil, images: nil, suit: nil, value: "14")]),
               Player(name: "Player 2", pile: [Card(code: "KH", image: nil, images: nil, suit: nil, value: "13")])
           ]
           viewModel.isGameStarted = true

           // Act
           viewModel.playRound()

           // Assert
           let expectation = XCTestExpectation(description: "Round should be played and determine a winner")
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               XCTAssertTrue(self.viewModel.currentRoundWinner == "Player 1" || self.viewModel.currentRoundWinner == "Player 2", "The round winner should be one of the players")
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 5.0)
       }

       func testRestartGame() {
           // Arrange
           viewModel.players = [Player(name: "Player 1", pile: [Card(code: "AS", image: nil, images: nil, suit: nil, value: "14")])]
           viewModel.currentRoundWinner = "Player 1"
           viewModel.deckId = "testDeckId"
           viewModel.isGameStarted = true

           // Act
           viewModel.restartGame()

           // Assert
           XCTAssertTrue(viewModel.players.isEmpty, "Players should be cleared")
           XCTAssertEqual(viewModel.currentRoundWinner, "", "Current round winner should be reset")
           XCTAssertEqual(viewModel.deckId, "", "Deck ID should be reset")
           XCTAssertFalse(viewModel.isGameStarted, "Game should be stopped")
       }
    
    func testDetermineRoundWinnerWithSingleWinner() {
           // Given
        viewModel.players = [
            Player(name: "Player 1", pile: [Card(code: "AS", image: nil, images: nil, suit: nil, value: "14")]),
            Player(name: "Player 2", pile: [Card(code: "KH", image: nil, images: nil, suit: nil, value: "13")])
        ]
        let drawnCards = [(viewModel.players[0], viewModel.players[0].pile![0]), (viewModel.players[1], viewModel.players[1].pile![0])]

           // When
        let winner = viewModel.determineRoundWinner(drawnCards: drawnCards)

           // Then
           XCTAssertEqual(winner.name, "Player 1")
       }
    
    func testDetermineRoundWinnerWithTieBreakOnPileCount() {
            // Given
        viewModel.players = [
            Player(name: "Player 1", pile: [Card(code: "AS", image: nil, images: nil, suit: nil, value: "14"), Card(code: "AS", image: nil, images: nil, suit: nil, value: "11")]),
            Player(name: "Player 2", pile: [Card(code: "KH", image: nil, images: nil, suit: nil, value: "14"), Card(code: "AS", image: nil, images: nil, suit: nil, value: "2"), Card(code: "AS", image: nil, images: nil, suit: nil, value: "4")])
        ]
        let drawnCards = [(viewModel.players[0], viewModel.players[0].pile![0]), (viewModel.players[1], viewModel.players[1].pile![0])]

            // When
            let winner = viewModel.determineRoundWinner(drawnCards: drawnCards)

            // Then
            XCTAssertEqual(winner.name, "Player 2") // Player 2 should win due to more cards in pile
        }
}
