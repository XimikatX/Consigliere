//
//  HomeController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 09/04/2025.
//

import UIKit

class HomeScreenController: UIViewController {
    
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
        // print("New Game button pressed.")
        self.navigationController?.pushViewController(
            OngoingGameScreenController(), animated: true)
    }

}

#Preview {
    {
        let navController = UINavigationController(
            rootViewController: HomeScreenController())
        navController.navigationBar.prefersLargeTitles = true
        navController.pushViewController(OngoingGameScreenController(), animated: false)
        return navController
    }()
}
