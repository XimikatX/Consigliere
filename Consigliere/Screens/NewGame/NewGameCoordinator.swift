//
//  NewGameCoordinator.swift
//  Consigliere
//
//  Created by Aleksey Boris on 22/05/2025.
//

import UIKit

class NewGameCoordinator {
    
    private let navController: UINavigationController
    
    var onCancel: (() -> Void)?
    var onStartGame: (([Player]) -> Void)?
    
    init(navController: UINavigationController) {
        self.navController = navController
    }
    
    func start() {
        let viewModel = NewGameViewModel(nicknames: mockPlayerNicknames())
        let playerInputVC = PlayerInputViewController(viewModel: viewModel)
        playerInputVC.onCancel = onCancel
        playerInputVC.onDone = { [weak self] in
            let roleSelectionVC = RoleSelectionViewController(viewModel: viewModel)
            roleSelectionVC.onStartGame = {
                self?.onStartGame?(viewModel.players)
            }
            self?.navController.pushViewController(roleSelectionVC, animated: true)
        }
        navController.viewControllers = [playerInputVC]
    }
    
}
