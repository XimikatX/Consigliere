//
//  Player.swift
//  Consigliere
//
//  Created by Aleksey Boris on 27/04/2025.
//

import Foundation

enum Role : Codable {
    case citizen, mafia, don, sheriff
}

struct Player : Equatable, Codable {
    let index: Int
    let nickname: String
    let role: Role?
    let isAlive: Bool
    var foulsCount: Int = 0
    var isMuted: Bool = false
    var hasTechFoul: Bool = false
    
    init(index: Int, nickname: String) {
        self.index = index
        self.nickname = nickname
        self.role = nil
        self.isAlive = true
    }
}
