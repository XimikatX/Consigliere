//
//  OngoingGame.swift
//  Consigliere
//
//  Created by Aleksey Boris on 20/05/2025.
//

struct GameState: Codable {
    var players: [Player] = .init()
    var phaseState: GamePhaseState = .init()
    var nominatedPlayerIndices: [Int] = []
    var discussionStartingPlayerIndex: Int = 0


    mutating func advancePhase() {
        if phaseState.currentPhase == .voting {
                nominatedPlayerIndices.removeAll()
            }
        phaseState.advance()
        
        if phaseState.currentPhase == .voting {
                updateDiscussionStartingPlayerIndex()
        }
    }
    
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

    mutating func nominatePlayer(at index: Int) {
        guard !nominatedPlayerIndices.contains(index) else { return }
        nominatedPlayerIndices.append(index)
        print("🔸 Номинированы игроки с индексами: \(nominatedPlayerIndices)")
    }


    mutating func resetNominations() {
        nominatedPlayerIndices.removeAll()
    }
    
    mutating func updateDiscussionStartingPlayerIndex() {
        let totalPlayers = players.count
        var offset = 1

        while offset <= totalPlayers {
            let nextIndex = (discussionStartingPlayerIndex + offset) % totalPlayers
            if players[nextIndex].isAlive {
                discussionStartingPlayerIndex = nextIndex
                break
            }
            offset += 1
        }
    }



    
}
extension GameState {
    var alivePlayers: [Player] {
        players.filter { $0.isAlive }
    }
    
    var alivePlayersCount: Int {
        alivePlayers.count
    }
}

extension GameState {
    enum GameResult {
        case mafiaWin
        case citizenWin
        case ongoing
    }

    var gameResult: GameResult {
        let aliveMafia = alivePlayers.filter { $0.role == .mafia || $0.role == .don }.count
        let aliveCivilians = alivePlayers.filter { $0.role == .citizen || $0.role == .sheriff }.count
        
        if aliveMafia == 0 {
            return .citizenWin
        } else if aliveMafia >= aliveCivilians {
            return .mafiaWin
        } else {
            return .ongoing
        }
    }
}

extension GameState {
    init(players: [Player]) {
        self.players = players.map { player in
            var copy = player
            copy.isAlive = true
            // Сохраняем роль игрока, если она была установлена
            copy.role = player.role
            return copy
        }
        self.phaseState = .init()
        self.nominatedPlayerIndices = []
    }
}

