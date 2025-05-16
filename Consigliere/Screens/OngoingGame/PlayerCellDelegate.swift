//
//  PlayerCellDelegate.swift
//  Consigliere
//
//  Created by Aleksey Boris on 11/05/2025.
//

import Foundation

protocol PlayerCellDelegate {
    
    func assignFoulToPlayer(at index: Int)
    func removeFoulFromPlayer(at index: Int)
    
    func toggleMuteForPlayer(at index: Int)
    
}
