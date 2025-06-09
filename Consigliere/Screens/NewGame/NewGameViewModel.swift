//
//  NewGameViewModel.swift
//  Consigliere
//
//  Created by Aleksey Boris on 21/05/2025.
//

import Foundation
import Combine


class NewGameViewModel {
    
    @Published private(set) var playerNicknames: [String]
    @Published private(set) var selectedRoles: [Role?]
        
    let repository: GameStateRepository
    
    init(
        nicknames: [String] = .init(repeating: "", count: 10),
        repository: GameStateRepository 
    ) {
        self.repository = repository
        self.playerNicknames = nicknames
        self.selectedRoles = .init(repeating: nil, count: 10)
    }
    
    func setPlayerNickname(_ nickname: String, forIndex index: Int) {
        playerNicknames[index] = nickname
    }
    
    func setRole(_ role: Role, forIndex index: Int) {
        print("🔄 Установлена роль \(role.rawValue) для игрока \(index)")
        selectedRoles[index] = role
    }
    
    var players: [Player] {
        (0..<10).compactMap { index in
            guard let role = selectedRoles[index] else { return nil }
            return Player(index: index, nickname: playerNicknames[index], role: role)
        }
    }

    
}

func mockPlayerNicknames() -> [String] {
    return [
        "Me", "Kangaroo", "Bumblebee With Very Long Nickname Which Won't Fit", "Cheetah", "Giraffe",
        "Ferret", "Elephant", "Octopus", "Penguin", "Chinchilla"
    ]
}
