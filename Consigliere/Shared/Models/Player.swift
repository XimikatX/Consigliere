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
    let nickname: String
    let role: Role?
    let isAlive: Bool
    var foulsCount: Int = 0
    var isMuted: Bool = false
    var hasTechFoul: Bool = false
    
    init(index: Int, nickname: String, role: Role? = nil) {
        self.index = index
        self.nickname = nickname
        self.role = nil
        self.isAlive = true
    }
}
