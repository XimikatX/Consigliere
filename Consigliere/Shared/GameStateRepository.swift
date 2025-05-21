//
//  OngoingGameRepository.swift
//  Consigliere
//
//  Created by Aleksey Boris on 20/05/2025.
//

import Foundation

protocol GameStateRepository {
    func loadGameState(completion: @escaping (Result<GameState?, Error>) -> Void)
    func saveGameState(gameState: GameState, completion: @escaping (Result<Void, Error>) -> Void)
}


class InMemoryGameStateRepository : GameStateRepository {
    
    private var gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    func loadGameState(completion: @escaping (Result<GameState?, Error>) -> Void) {
        completion(.success(gameState))
    }
    
    func saveGameState(gameState: GameState, completion: @escaping (Result<Void, Error>) -> Void) {
        self.gameState = gameState
        completion(.success(()))
    }
    
}


func mockGameState() -> GameState {
    let playerNicknames = [
        "Tortoise", "Bumblebee With Very Long Nickname Which Won't Fit", "Kangaroo", "Cheetah", "Giraffe",
        "Ferret", "Elephant", "Octopus", "Penguin", "Chinchilla"
    ]
    return GameState(
        players: playerNicknames.enumerated().map { index, nickname in
                .init(index: index, nickname: nickname)
        }
    )
}
