//
//  SceneDelegate.swift
//  Consigliere
//
//  Created by Aleksey Boris on 11/04/2025.
//

import UIKit
import UserNotifications


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error = error {
                        print("Notification permission error: \(error)")
                    }
        }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navController = UINavigationController(rootViewController: HomeScreenController())
        navController.navigationBar.prefersLargeTitles = true

        // navController.pushViewController(OngoingGameScreenController(), animated: false)
        
        let gameStateRepository = UserDefaultsGameStateRepository()
        gameStateRepository.loadGameState() { result in
            if (try? result.get()) != nil {
                let viewModel = OngoingGameViewModel(repository: gameStateRepository)
                navController.pushViewController(OngoingGameViewController(viewModel: viewModel), animated: false)
            }
        }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

    }



}

