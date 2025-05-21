//
//  OngoingGame.swift
//  Consigliere
//
//  Created by Aleksey Boris on 20/05/2025.
//


struct GameState : Codable {
    var players: [Player]
    
    mutating func assignFoulToPlayer(at index: Int) {
        players[index].foulsCount += 1
        if players[index].foulsCount == 3 {
            players[index].isMuted = true
        }
    }
    
    mutating func removeFoulFromPlayer(at index: Int) {
        players[index].foulsCount -= 1
        if players[index].foulsCount < 3 {
            players[index].isMuted = false
        }
    }
    
    mutating func toggleMuteForPlayer(at index: Int) {
        players[index].isMuted.toggle()
    }
    
    mutating func toggleTechFoulForPlayer(at index: Int) {
        players[index].hasTechFoul.toggle()
    }
    
}
