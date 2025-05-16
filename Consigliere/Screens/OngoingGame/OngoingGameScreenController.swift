//
//  OngoingGameScreenControllerViewController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 16/04/2025.
//

import UIKit

let playerNicknames = [
    "Tortoise", "Bumblebee With Very Long Nickname Which Won't Fit", "Kangaroo", "Cheetah", "Giraffe",
    "Ferret", "Elephant", "Octopus", "Penguin", "Chinchilla"
]

// protocol OngoingGameDataStore {
//
// }

// class OngoingGameJsonStore : OngoingGameDS

final class OngoingGameScreenController: UIViewController {
    
    private var players: [Player] = playerNicknames.enumerated().map { index, nickname in
        Player(index: index, nickname: nickname, role: .citizen, foulsCount: index % 4)
    }
    
    private let playerTable: UITableView = {
        let tableView = UITableView()
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.id)
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ongoing Game"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .systemIndigo
        // navigationItem.rightBarButtonItems = [optionsButton, toggleRoleVisibilityButton]
        
        view.backgroundColor = .systemBackground
        
        playerTable.dataSource = self
        playerTable.delegate = self
        
        view.addSubview(playerTable)
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
}

extension OngoingGameScreenController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerNicknames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.id, for: indexPath)
                as? PlayerCell
        else {
            fatalError("OngoingGameScreenController could not dequeue a PlayerCell.")
        }

        cell.configure(for: players[indexPath.row])
        cell.delegate = self
        cell.isExpanded = indexPath == selectedIndexPath

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == selectedIndexPath ? 108 : 56
    }
    
}

extension OngoingGameScreenController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsToReload: [IndexPath] = []
        
        if indexPath == selectedIndexPath {
            indexPathsToReload = [indexPath]
            selectedIndexPath = nil
        } else if let selectedIndexPath {
            indexPathsToReload = [indexPath, selectedIndexPath]
            self.selectedIndexPath = indexPath
        } else {
            indexPathsToReload = [indexPath]
            selectedIndexPath = indexPath
        }
        
        // FIXME: This should be done using .reconfigureRows with proper animation
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
}

extension OngoingGameScreenController: PlayerCellDelegate {
    
    func assignFoulToPlayer(at index: Int) {
        players[index].foulsCount += 1
        UIView.performWithoutAnimation {
            playerTable.reconfigureRows(at: [.init(row: index, section: 0)])
        }
    }
    
    func removeFoulFromPlayer(at index: Int) {
        players[index].foulsCount -= 1
        if players[index].foulsCount < 3 {
            players[index].isMuted = false
        }
        UIView.performWithoutAnimation {
            playerTable.reconfigureRows(at: [.init(row: index, section: 0)])
        }
    }
    
    func toggleMuteForPlayer(at index: Int) {
        players[index].isMuted.toggle()
        UIView.performWithoutAnimation {
            playerTable.reconfigureRows(at: [.init(row: index, section: 0)])
        }
    }
    
}


#Preview {
    OngoingGameScreenController()
}
