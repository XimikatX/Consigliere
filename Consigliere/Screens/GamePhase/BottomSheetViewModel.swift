////
////  BottomSheetViewModel.swift
////  Consigliere
////
////  Created by Yehor Kuzmych on 27/05/2025.
////
//
//import Combine
//
//class BottomSheetViewModel{
//    
//    
//    private let gameStateRepository: GameStateRepository
//    
//    @Published var gameState: GameState?
//
//    
//    init(repository: GameStateRepository) {
//        gameStateRepository = repository
//        gameStateRepository.loadGameState { [weak self] result in
//            guard let self else { return }
//            gameState = try? result.get()
//        }
//    }
//    
//    var currentPhase: GamePhase {
//        gameState!.phaseState.currentPhase
//    }
//    
//    func assignFoulToPlayer(at index: Int) {
//        gameState?.assignFoulToPlayer(at: index)
//        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
//    }
//    
//    func removeFoulFromPlayer(at index: Int) {
//        gameState?.removeFoulFromPlayer(at: index)
//        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
//    }
//    
//    func toggleMuteForPlayer(at index: Int) {
//        gameState?.toggleMuteForPlayer(at: index)
//        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
//    }
//    
//    func toggleTechFoulForPlayer(at index: Int) {
//        gameState?.toggleTechFoulForPlayer(at: index)
//        gameStateRepository.saveGameState(gameState: gameState!) { _ in }
//    }
//    
//    func nominatePlayer(at index: Int) {
//        guard var state = gameState else { return }
//        state.nominatePlayer(at: index)
//        gameState = state
//        print("🔥 nominatedPlayerIndices updated: \(state.nominatedPlayerIndices)")
//    }
//
//    
//    func advancePhase() {
//        guard var state = gameState else { return }
//
//        let oldPhase = state.phaseState.currentPhase
//        state.advancePhase()
//        
//        if oldPhase == .voting {
//            state.resetNominations()
//        }
//
//        gameState = state
//        gameStateRepository.saveGameState(gameState: state) { _ in }
//    }
//
//}
