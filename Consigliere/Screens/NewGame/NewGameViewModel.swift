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
    
    init(nicknames: [String] = .init(repeating: "", count: 10)) {
        playerNicknames = nicknames
        selectedRoles = .init(repeating: nil, count: 10)
    }
    
    func setPlayerNickname(_ nickname: String, forIndex index: Int) {
        playerNicknames[index] = nickname
    }
    
    func setRole(_ role: Role, forIndex index: Int) {
        selectedRoles[index] = role
    }
    
    var players: [Player] {
        get {
            (0..<10).map { index in
                Player(index: index, nickname: playerNicknames[index], role: selectedRoles[index])
            }
        }
    }
    
}

func mockPlayerNicknames() -> [String] {
    return [
        "", "Kangaroo", "Bumblebee With Very Long Nickname Which Won't Fit", "Cheetah", "Giraffe",
        "Ferret", "Elephant", "Octopus", "Penguin", "Chinchilla"
    ]
}
