//
//  BottomSheetViewController.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 27/05/2025.
//

import UIKit
import Combine

class BottomSheetViewController: UIViewController {
    
    private let viewModel: BottomSheetViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let timerView = TimerView()
    
    init(viewModel: BottomSheetViewModel) {
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

    private func setupBindings() {
        viewModel.$phaseState
            .map { $0.currentPhase }
            .removeDuplicates()
            .sink { [weak self] phase in
                self?.updateUI(for: phase)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for phase: GamePhase) {
        configureContent(for: phase)
    }

    private func configureContent(for phase: GamePhase) {
        // Удаляем все подвиды
        view.subviews.forEach { $0.removeFromSuperview() }

        switch phase {
        case .initialNight:
            configureInitialNight()
        case .discussion:
                configureDiscussionPhase()
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
    }


    @objc private func handleNextPhase() {
        viewModel.advancePhase()
    }

    private func configureDiscussionPhase() {
        
        let discussionView = DiscussionPhaseView(totalPlayers: 10)
        discussionView.translatesAutoresizingMaskIntoConstraints = false
        discussionView.onNextPhase = { [weak self] in
            self?.viewModel.advancePhase()
        }

        view.addSubview(discussionView)

        NSLayoutConstraint.activate([
            discussionView.topAnchor.constraint(equalTo: view.topAnchor),
            discussionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discussionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discussionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}
