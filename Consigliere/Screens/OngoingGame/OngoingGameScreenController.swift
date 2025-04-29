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

final class OngoingGameScreenController: UIViewController {
    
    private let playerTable: UITableView = {
        let tableView = UITableView()
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.id)
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
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

        cell.configure(index: indexPath.row, nickname: playerNicknames[indexPath.row])
        cell.isExpanded = indexPath == selectedIndexPath

        return cell
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
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
}




#Preview {
    OngoingGameScreenController()
}
