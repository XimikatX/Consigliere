//
//  BottomSheetViewModel.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 27/05/2025.
//

import Combine
import Foundation

final class BottomSheetViewModel: ObservableObject {
    @Published var phaseState: GamePhaseState
    

    var currentPhase: GamePhase {
        phaseState.currentPhase
    }

    init(phaseState: GamePhaseState = GamePhaseState()) {
        self.phaseState = phaseState
    }

    func advancePhase() {
        phaseState.advance()
        objectWillChange.send()
    }
}
