//
//  OngoingGameViewModel.swift
//  Consigliere
//
//  Created by Aleksey Boris on 20/05/2025.
//

import Combine

class OngoingGameViewModel {
    
    private let gameStateRepository: GameStateRepository
    
    @Published var gameState: GameState?
    
    init(repository: GameStateRepository) {
        gameStateRepository = repository
        gameStateRepository.loadGameState { [weak self] result in
            guard let self else { return }
            gameState = try? result.get()
        }
    }
    
    func assignFoulToPlayer(at index: Int) {
        gameState?.assignFoulToPlayer(at: index)
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
    }
    
    func removeFoulFromPlayer(at index: Int) {
        gameState?.removeFoulFromPlayer(at: index)
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
    }
    
    func toggleMuteForPlayer(at index: Int) {
        gameState?.toggleMuteForPlayer(at: index)
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
    }
    
    func toggleTechFoulForPlayer(at index: Int) {
        gameState?.toggleTechFoulForPlayer(at: index)
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
    }
    
}
