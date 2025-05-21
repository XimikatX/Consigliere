//
//  HomeController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 09/04/2025.
//

import UIKit

class HomeScreenController: UIViewController {
    
    let nicknames: [String]
    
    init(nicknames: [String]) {
        self.nicknames = nicknames
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let newGameButton: UIButton = {
        let button = UIButton()
        button.configuration = {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "New Game"
            configuration.image = UIImage(systemName: "plus")
            configuration.imagePadding = 4.0
            return configuration
        }()
        button.tintColor = .systemIndigo
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        self.navigationItem.largeTitleDisplayMode = .always

        view.backgroundColor = .systemBackground
        view.addSubview(newGameButton)
        newGameButton.addTarget(self, action: #selector(handleNewGame), for: .touchUpInside)
        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newGameButton.widthAnchor.constraint(equalToConstant: 200),
            newGameButton.heightAnchor.constraint(equalToConstant: 50),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

    }

    @objc func handleNewGame() {
//        let repository = UserDefaultsGameStateRepository()
//        repository.saveGameState(gameState: mockGameState()) { _ in }
//        let viewModel = OngoingGameViewModel(gameStateRepository: repository)
//        self.navigationController?.pushViewController(
//            OngoingGameScreenController(viewModel: viewModel), animated: true)
    
        let navVC = UINavigationController(rootViewController: NewGameScreenController())
        present(navVC, animated: true)

    }

}

