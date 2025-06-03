import UIKit

final class VotingPhaseView: UIView {

    private let titleLabel = UILabel()
    private let timerView = TimerView()
    private let nextButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let nominatedContainerStackView = UIStackView()
    private let nominatedTitleLabel = UILabel()
    private let nominatedPlayersStackView = UIStackView()
    private let noNominationsLabel = UILabel()

    private var nominatedIndices: [Int] = []
    private var currentNomineeIndex = 0
    var onNextPhase: (() -> Void)?
    var onPlayerVotedOut: ((Int) -> Void)?
    private var isFinalWordsPhase = false
    
    private var nomineeButtons: [UIButton] = []
    private var selectedNomineeIndex: Int?
    
    private var noNominationsNextButtonConstraint: NSLayoutConstraint?
    private var defaultNextButtonTopConstraint: NSLayoutConstraint?
    
    private var isSelectionLocked = false






    init() {
        super.init(frame: .zero)
        setupView()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        titleLabel.text = "Voting"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        configureButton(nextButton, title: "Next", color: .systemGray, systemImage: "arrow.right", isTrailing: true)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        configureButton(previousButton, title: "Previous", color: .systemGray, systemImage: "arrow.left", isTrailing: false)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)

        nominatedTitleLabel.text = "Select a nominee:"
        nominatedTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nominatedTitleLabel.textAlignment = .center

        nominatedPlayersStackView.axis = .horizontal
        nominatedPlayersStackView.spacing = 8
        nominatedPlayersStackView.alignment = .center

        nominatedContainerStackView.axis = .vertical
        nominatedContainerStackView.spacing = 4
        nominatedContainerStackView.alignment = .center
        nominatedContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        nominatedContainerStackView.addArrangedSubview(nominatedTitleLabel)
        nominatedContainerStackView.addArrangedSubview(nominatedPlayersStackView)
        addSubview(nominatedContainerStackView)

        noNominationsLabel.text = "No nominated players"
        noNominationsLabel.font = .systemFont(ofSize: 16)
        noNominationsLabel.textColor = .secondaryLabel
        noNominationsLabel.textAlignment = .center
        noNominationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(noNominationsLabel)
        addSubview(titleLabel)
        addSubview(timerView)
        addSubview(nextButton)
        addSubview(previousButton)

        timerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        
        defaultNextButtonTopConstraint = nextButton.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 8)
        defaultNextButtonTopConstraint?.isActive = true

        noNominationsNextButtonConstraint = nextButton.topAnchor.constraint(equalTo: noNominationsLabel.bottomAnchor, constant: 16)
        noNominationsNextButtonConstraint?.isActive = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            nominatedContainerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            nominatedContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nominatedContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            noNominationsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            noNominationsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            noNominationsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            timerView.topAnchor.constraint(equalTo: nominatedContainerStackView.bottomAnchor, constant: 16),
            timerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            timerView.heightAnchor.constraint(equalToConstant: 200),

            previousButton.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 8),
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            previousButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            previousButton.heightAnchor.constraint(equalToConstant: 40),

            
            nextButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            nextButton.heightAnchor.constraint(equalToConstant: 40),

            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }

    private func configureButton(_ button: UIButton, title: String, color: UIColor, systemImage: String, isTrailing: Bool) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: systemImage)
            config.imagePadding = 6
            config.imagePlacement = isTrailing ? .trailing : .leading
            config.cornerStyle = .medium
            config.baseForegroundColor = .white
            config.baseBackgroundColor = color
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(systemName: systemImage), for: .normal)
            button.tintColor = .white
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = color
            button.layer.cornerRadius = 10
            button.semanticContentAttribute = isTrailing ? .forceRightToLeft : .forceLeftToRight
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: isTrailing ? 6 : -6, bottom: 0, right: isTrailing ? -6 : 6)
        }
    }

    func updateNominatedPlayers(_ indices: [Int]?) {
        nominatedPlayersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let indices = indices, !indices.isEmpty else {
            nominatedIndices = []
            isFinalWordsPhase = true
            nominatedContainerStackView.isHidden = true
            noNominationsLabel.isHidden = false
            timerView.isHidden = true
            noNominationsNextButtonConstraint?.isActive = true
            defaultNextButtonTopConstraint?.isActive = false
            configureButton(nextButton,
                            title: "Next Phase",
                            color: .systemIndigo,
                            systemImage: "arrow.right",
                            isTrailing: true)
            previousButton.isHidden = true
            noNominationsLabel.isHidden = false
            return
        }
        
        noNominationsNextButtonConstraint?.isActive = false
        defaultNextButtonTopConstraint?.isActive = true


        nominatedIndices = indices
        currentNomineeIndex = 0
        nominatedContainerStackView.isHidden = false
        noNominationsLabel.isHidden = true
        timerView.isHidden = false

        nomineeButtons = []

        for (i, index) in indices.enumerated() {
            let badge = NumberBadge()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.setNumber(index + 1)
            badge.widthAnchor.constraint(equalToConstant: 40).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 40).isActive = true
            badge.tag = i
            badge.widthAnchor.constraint(equalToConstant: 28).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 28).isActive = true

            // Добавляем тап-жест
            let tap = UITapGestureRecognizer(target: self, action: #selector(nomineeBadgeTapped(_:)))
            badge.addGestureRecognizer(tap)
            badge.isUserInteractionEnabled = true

            nomineeButtons.append(UIButton()) // для сохранения структуры, если используешь `selectedNomineeIndex`
            nominatedPlayersStackView.addArrangedSubview(badge)
        }

        isFinalWordsPhase = false
        updateUI()
    }


    private func updateUI() {
        guard !nominatedIndices.isEmpty else { return }

        if isFinalWordsPhase {
            timerView.setSpeechLabel(text: "Final Words")
            
            // Показ окончательного выбора
            if let selectedIndex = selectedNomineeIndex {
                let nomineeNumber = nominatedIndices[selectedIndex] + 1
                nominatedTitleLabel.text = "City votes out player number: \(nomineeNumber)"
            }

            configureButton(nextButton,
                            title: "Next Phase",
                            color: .systemIndigo,
                            systemImage: "arrow.right",
                            isTrailing: true)

            previousButton.isHidden = false
            return
        }

        // Название фазы и надпись о выборе
        timerView.setSpeechLabel(text: "Player \(nominatedIndices[currentNomineeIndex] + 1)")

        if isSelectionLocked {
            if let selectedIndex = selectedNomineeIndex {
                let nomineeNumber = nominatedIndices[selectedIndex] + 1
                nominatedTitleLabel.text = "City votes out player number: \(nomineeNumber)"
            }
        } else {
            nominatedTitleLabel.text = "Select a nominee:"
        }

        let isLastNominee = currentNomineeIndex == nominatedIndices.count - 1
        let buttonTitle = isLastNominee ? "Final Words" : "Next"
        let buttonColor = isLastNominee ? UIColor.systemRed : UIColor.systemGray

        configureButton(nextButton,
                        title: buttonTitle,
                        color: buttonColor,
                        systemImage: "arrow.right",
                        isTrailing: true)

        nextButton.isEnabled = !isLastNominee || selectedNomineeIndex != nil
        previousButton.isHidden = currentNomineeIndex == 0
    }


    @objc private func nextTapped() {
        if isFinalWordsPhase {
            if let selectedIndex = selectedNomineeIndex {
                let playerIndex = nominatedIndices[selectedIndex]
                onPlayerVotedOut?(playerIndex) 
            }
            onNextPhase?()
            return
        }

        if currentNomineeIndex < nominatedIndices.count - 1 {
            currentNomineeIndex += 1
        } else {
            guard selectedNomineeIndex != nil else { return }
            isFinalWordsPhase = true
            isSelectionLocked = true
        }

        updateUI()
    }




    @objc private func previousTapped() {
        if isFinalWordsPhase {
            isFinalWordsPhase = false
            isSelectionLocked = false
            updateUI()
            return
        }

        if currentNomineeIndex > 0 {
            currentNomineeIndex -= 1
            updateUI()
        }
    }
     
    @objc private func nomineeBadgeTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, !isSelectionLocked else { return }

        // Сброс выделения
        for case let badge as NumberBadge in nominatedPlayersStackView.arrangedSubviews {
            badge.backgroundColor = R.Colors.Label.primary
        }

        // Выделение текущего
        view.backgroundColor = .systemRed
        selectedNomineeIndex = view.tag

        updateUI()
    }




}
