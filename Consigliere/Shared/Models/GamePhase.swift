//
//  GamePhase.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 27/05/2025.
//

import Foundation

enum GamePhase: String, Codable {
    case initialNight
    case discussion
    case voting
    case night
}

struct GamePhaseState: Codable {
    var currentPhase: GamePhase
    var isFirstCycle: Bool

    init() {
        self.currentPhase = .initialNight
        self.isFirstCycle = true
    }

    mutating func advance() {
        switch currentPhase {
        case .initialNight:
            currentPhase = .discussion

        case .discussion:
            currentPhase = .voting

        case .voting:
            currentPhase = .night

        case .night:
            if isFirstCycle {
                isFirstCycle = false
            }
            currentPhase = .discussion
        }
    }
}
