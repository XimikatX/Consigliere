//
//  Player.swift
//  Consigliere
//
//  Created by Aleksey Boris on 27/04/2025.
//

import Foundation

enum Role {
    case citizen, mafia, don, sheriff
}

struct Player {
    let index: Int
    let nickname: String
    let role: Role
    let isAlive: Bool = true
    var foulsCount: Int = 0
    var isMuted: Bool = false
    var hasTechFoul: Bool = false
}
