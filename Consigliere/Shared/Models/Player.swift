//
//  Player.swift
//  Consigliere
//
//  Created by Aleksey Boris on 27/04/2025.
//

import Foundation

enum Role: String, CaseIterable, Codable {
    case citizen = "Citizen"
    case mafia = "Mafia"
    case don = "Don"
    case sheriff = "Sheriff"
}

struct Player : Equatable, Codable {
    let index: Int
    var nickname: String
    var role: Role
    var isAlive: Bool
    var foulsCount: Int = 0
    var isMuted: Bool = false
    var hasTechFoul: Bool = false
    
    init(index: Int, nickname: String, role: Role) {
        self.index = index
        self.nickname = nickname
        self.role = role
        self.isAlive = true
    }
}
