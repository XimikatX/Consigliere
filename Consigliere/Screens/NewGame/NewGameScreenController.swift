//
//  NewGameScreenController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 09/04/2025.
//

import UIKit

class NewGameScreenController: UIViewController {
    
    private let playerTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(PlayerInputCell.self, forCellReuseIdentifier: PlayerInputCell.id)
        return table
    }()

    private let startGameButton: UIButton = {
        let button = UIButton()
        button.configuration = {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Start Game"
            // configuration.image = nil
            return configuration
        }()
        button.tintColor = .systemIndigo
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Game"
        navigationItem.largeTitleDisplayMode = .never

        view.backgroundColor = .systemBackground

        configurePlayerTable()
        configureStartGameButton()
    }

    private func configurePlayerTable() {

        view.addSubview(playerTable)
        playerTable.dataSource = self
        playerTable.delegate = self
        playerTable.rowHeight = 52
        
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }

    private func configureStartGameButton() {

        view.addSubview(startGameButton)
        startGameButton.addTarget(
            self, action: #selector(startGame), for: .touchUpInside)

        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startGameButton.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.8, constant: -32),
            startGameButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            startGameButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            startGameButton.heightAnchor.constraint(equalToConstant: 50),
        ])

    }

    @objc func startGame() {
        print("Start Game button tapped.")
    }

}

extension NewGameScreenController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
        return 10
    }

    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerInputCell.id, for: indexPath)
                as? PlayerInputCell
        else {
            fatalError("NewGameScreenController could not dequeue a PlayerInputCell.")
        }

        cell.configure(forIndex: indexPath.row, delegate: self)

        return cell
    }

}

extension NewGameScreenController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerInputCell
        else {
            fatalError("cellForRow(at:) did not return a PlayerInputCell.")
        }
        cell.nicknameTextField.becomeFirstResponder()
    }

}

extension NewGameScreenController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let row = textField.tag, nextRow = row + 1
        guard nextRow < 10 else {
            textField.resignFirstResponder()
            return true
        }
        let nextCellIndexPath = IndexPath(row: nextRow, section: 0)
        playerTable.scrollToRow(at: nextCellIndexPath, at: .none, animated: false)
        guard let cell = playerTable.cellForRow(at: nextCellIndexPath) as? PlayerInputCell
        else {
            fatalError("cellForRow(at:) did not return a PlayerInputCell.")
        }
        cell.nicknameTextField.becomeFirstResponder()
        return true
    }
    
}


#Preview {
    NewGameScreenController()
}
