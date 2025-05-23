//
//  HomeController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 09/04/2025.
//

import UIKit

class HomeScreenController: UIViewController {
    
    private var newGameCoordinator: NewGameCoordinator?
    
    private lazy var newGameButton: UIButton = {
        let button = UIButton()
        button.configuration = {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "New Game"
            configuration.image = UIImage(systemName: "plus")
            configuration.imagePadding = 4.0
            return configuration
        }()
        button.addTarget(self, action: #selector(onNewGameTapped), for: .touchUpInside)
        button.tintColor = .systemIndigo
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        self.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        
        view.addSubview(newGameButton)
    
        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newGameButton.widthAnchor.constraint(equalToConstant: 200),
            newGameButton.heightAnchor.constraint(equalToConstant: 50),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

    }

    @objc func onNewGameTapped() {
    
        let navController = UINavigationController()
        let coordinator = NewGameCoordinator(navController: navController)
        
        coordinator.onCancel = { [weak self] in
            self?.dismiss(animated: true) {
                self?.newGameCoordinator = nil
            }
        }
        coordinator.onStartGame = { [weak self] players in
            self?.dismiss(animated: true) {
                // FIXME: This doesn't animate simultaneously
                let gameStateRepository = UserDefaultsGameStateRepository()
                gameStateRepository.saveGameState(gameState: GameState(players: players)) { _ in }
                let ongoingGameVC = OngoingGameViewController(
                    viewModel: OngoingGameViewModel(repository: gameStateRepository))
                self?.navigationController?.pushViewController(ongoingGameVC, animated: true)
                self?.newGameCoordinator = nil
            }
        }
        
        newGameCoordinator = coordinator
        coordinator.start()
        present(navController, animated: true)

    }

}

