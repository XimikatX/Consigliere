//
//  OngoingGameViewModel.swift
//  Consigliere
//
//  Created by Aleksey Boris on 20/05/2025.
//

import Combine

class OngoingGameViewModel {
    
    let gameStateRepository: GameStateRepository
    
    @Published var gameState: GameState?
    
    @Published var areRolesVisible = false
    
    var killedLastNightPlayerIndex: Int?


    
    init(repository: GameStateRepository) {
        gameStateRepository = repository
        gameStateRepository.loadGameState { [weak self] result in
            guard let self else { return }
            gameState = try? result.get()
        }
    }
    
    var currentPhase: GamePhase {
        gameState!.phaseState.currentPhase
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
    
    func nominatePlayer(at index: Int) {
        gameState?.nominatePlayer(at: index)
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
        print("Nominated player at index: \(index)")
    }
    
    func killPlayer(at index: Int) {
        gameState?.players[index].isAlive = false
        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
        
    }

    func mafiaKill(playerIndex: Int?) {
        guard let index = playerIndex else {
            return
        }
        killPlayer(at: index)
    }
    
    func advancePhase() {
        guard var state = gameState else { return }
        state.advancePhase()
        gameState = state
        gameStateRepository.saveGameState(gameState: state) { _ in }
    }
}

extension OngoingGameViewModel {
    func checkForGameEnd(onWin: @escaping (GameState.GameResult) -> Void) {
        guard let state = gameState else { return }

        print("📋 Проверка конца игры. Живые игроки:")
        for player in state.alivePlayers {
            print("👤 \(player.nickname): \(player.role), isAlive: \(player.isAlive)")
        }

        let result = state.gameResult
        if result != .ongoing {
            gameState = nil
            gameStateRepository.clearGameState()
            onWin(result)
        }

    }

    
    func clearGameState() {
        gameState = nil
        gameStateRepository.clearGameState()
    }

}
