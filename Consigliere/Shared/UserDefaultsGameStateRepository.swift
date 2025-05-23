//
//  UserDefaultsGameStateRepository.swift
//  Consigliere
//
//  Created by Aleksey Boris on 21/05/2025.
//

import Foundation

class UserDefaultsGameStateRepository : GameStateRepository {
    
    private let gameStateKey = "gameState"
    
    func loadGameState(completion: @escaping (Result<GameState?, any Error>) -> Void) {
        if let data = UserDefaults.standard.data(forKey: gameStateKey) {
            let decoder = JSONDecoder()
            do {
                let gameState = try decoder.decode(GameState.self, from: data)
                completion(.success(gameState))
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.success(nil))
        }

    }
    
    func saveGameState(gameState: GameState, completion: @escaping (Result<Void, any Error>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(gameState)
            UserDefaults.standard.set(data, forKey: gameStateKey)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
}
