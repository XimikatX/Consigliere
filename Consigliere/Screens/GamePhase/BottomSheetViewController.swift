//
//  BottomSheetViewController.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 27/05/2025.
//

import UIKit
import Combine

class BottomSheetViewController: UIViewController {
    
    private let viewModel: OngoingGameViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let timerView = TimerView()
    
    init(viewModel: OngoingGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBindings()
    }
    
    var onContentHeightUpdate: ((CGFloat) -> Void)?
    




    private func setupBindings() {
        viewModel.$gameState
            .compactMap { $0?.phaseState.currentPhase }
            .removeDuplicates()
            .sink { [weak self] phase in
                self?.updateUI(for: phase)
            }
            .store(in: &cancellables)
        viewModel.$gameState
            .compactMap { $0?.nominatedPlayerIndices }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nominatedIndices in
                print("🔥 nominated updated: \(nominatedIndices)")
                print("📦 discussionView is: \(String(describing: self?.discussionView))")
                self?.discussionView?.updateNominatedPlayers(nominatedIndices)
            }
            .store(in: &cancellables)
        viewModel.$gameState
            .compactMap { $0?.nominatedPlayerIndices }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nominatedIndices in
                self?.discussionView?.updateNominatedPlayers(nominatedIndices)
                self?.votingView?.updateNominatedPlayers(nominatedIndices)
            }
            .store(in: &cancellables)

    }
    
    private func updateUI(for phase: GamePhase) {
        configureContent(for: phase)
    }

    private func configureContent(for phase: GamePhase) {
        view.subviews.forEach { $0.removeFromSuperview() }

        switch phase {
        case .initialNight:
            configureInitialNight()
        case .discussion:
            configureDiscussionPhase()
        case .voting:
            configureVotingPhase()
        case .night:
            configureNightPhase()
        default:
            break
        }
    }

    private func configureInitialNight() {
        titleLabel.text = "Initial Night. The city falls asleep, the mafia wakes up"

        let nextPhaseButton = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Next Phase"
            config.image = UIImage(systemName: "arrow.right")
            config.imagePadding = 6
            config.imagePlacement = .trailing
            config.baseBackgroundColor = .systemIndigo
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            nextPhaseButton.configuration = config
        } else {
            nextPhaseButton.setTitle("Next Phase", for: .normal)
            nextPhaseButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
            nextPhaseButton.tintColor = .white
            nextPhaseButton.setTitleColor(.white, for: .normal)
            nextPhaseButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            nextPhaseButton.backgroundColor = .systemIndigo
            nextPhaseButton.layer.cornerRadius = 10
            nextPhaseButton.semanticContentAttribute = .forceRightToLeft
            nextPhaseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }

        nextPhaseButton.addTarget(self, action: #selector(handleNextPhase), for: .touchUpInside)
        nextPhaseButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(timerView)
        view.addSubview(nextPhaseButton)
        
        for player in viewModel.gameState!.alivePlayers {
            print("👤 \(player.nickname): \(player.role), isAlive: \(player.isAlive)")
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            timerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timerView.heightAnchor.constraint(equalToConstant: 200),

            nextPhaseButton.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 8),
            nextPhaseButton.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            nextPhaseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nextPhaseButton.heightAnchor.constraint(equalToConstant: 40),
            nextPhaseButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])
        
        DispatchQueue.main.async {
            let contentHeight = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.onContentHeightUpdate?(contentHeight)
        }

    }


    @objc private func handleNextPhase() {
        viewModel.advancePhase()
    }
    
    private var discussionView: DiscussionPhaseView? = nil
    private var votingView: VotingPhaseView? = nil


    private func configureDiscussionPhase() {
        guard let gameState = viewModel.gameState else { return }

        let aliveIndices = gameState.alivePlayers.map { $0.index }
        let currentIndex = gameState.discussionStartingPlayerIndex
        let killedIndex = viewModel.killedLastNightPlayerIndex
        let discussion = DiscussionPhaseView(
            alivePlayerIndices: aliveIndices,
            startingPlayerIndex: currentIndex,
            killedLastNightPlayerIndex: killedIndex
        )
        
        print("🩸 Player killed last night: at index \(killedIndex ?? -1)")
        

        

        discussionView = discussion
        discussion.translatesAutoresizingMaskIntoConstraints = false
        
        discussion.onNextPhase = { [weak self] in
            self?.viewModel.advancePhase()
        }
        view.addSubview(discussion)

        NSLayoutConstraint.activate([
            discussion.topAnchor.constraint(equalTo: view.topAnchor),
            discussion.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discussion.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discussion.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        DispatchQueue.main.async {
            let contentHeight = discussion.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.onContentHeightUpdate?(contentHeight)
        }
    }


    
    
    private func configureVotingPhase() {
        let votingView = VotingPhaseView()

        votingView.onNextPhase = { [weak self] in
            self?.viewModel.advancePhase()
        }
        
        votingView.onPlayerVotedOut = { [weak self] playerIndex in
            self?.viewModel.killPlayer(at: playerIndex)
            print("Player \(playerIndex + 1) has been voted out and is now dead.")
            
            
            self?.viewModel.checkForGameEnd { [weak self] result in
                self?.presentGameOverAlert(result: result)
            }
            
        }


        votingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(votingView)

        NSLayoutConstraint.activate([
            votingView.topAnchor.constraint(equalTo: view.topAnchor),
            votingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            votingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            votingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Передаём текущих номинантов
        if let nominated = viewModel.gameState?.nominatedPlayerIndices {
            print("🟦 configureVotingPhase: nominated = \(nominated)")
            votingView.updateNominatedPlayers(nominated)
        }
        
        DispatchQueue.main.async {
            let contentHeight = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.onContentHeightUpdate?(contentHeight)
        }

    }

    private func configureNightPhase() {
        guard let alivePlayers = viewModel.gameState?.alivePlayers else { return }

        let nightView = NightPhaseView(alivePlayers: alivePlayers)
        nightView.translatesAutoresizingMaskIntoConstraints = false

        nightView.onNext = { [weak self] selectedIndex in
            self?.viewModel.mafiaKill(playerIndex: selectedIndex)
            self?.viewModel.killedLastNightPlayerIndex = selectedIndex
            if let killedIndex = self?.viewModel.killedLastNightPlayerIndex,
               let player = self?.viewModel.gameState?.players[safe: killedIndex] {
                print("🩸 Player killed last night: \(player.nickname) at index \(killedIndex)")
            } else {
                print("⚠️ Failed to retrieve killed player info")
            }

            self?.viewModel.gameState?.updateDiscussionStartingPlayerIndex()
            self?.viewModel.checkForGameEnd { [weak self] result in
                self?.presentGameOverAlert(result: result)
            }
            self?.viewModel.advancePhase()
        }

        view.addSubview(nightView)

        NSLayoutConstraint.activate([
            nightView.topAnchor.constraint(equalTo: view.topAnchor),
            nightView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nightView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        DispatchQueue.main.async {
            let contentHeight = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.onContentHeightUpdate?(contentHeight)
        }

    }
    
    private func presentGameOverAlert(result: GameState.GameResult) {
        let title = "Game Over"
        let message: String

        switch result {
        case .citizenWin:
            message = "Citizens win!"
        case .mafiaWin:
            message = "Mafia wins!"
        case .ongoing:
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back to Home screen", style: .default) { [weak self] _ in
            self?.viewModel.clearGameState()
            self?.navigateToHomeScreen()
        })

        present(alert, animated: true)
    }
    
    private func navigateToHomeScreen() {
        navigationController?.popToRootViewController(animated: true)
    }







}
