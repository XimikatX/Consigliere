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

struct PLayer {
    let nickname: String
    let role: Role
    var foulsCount: Int = 0
    var muted: Bool = false
}
