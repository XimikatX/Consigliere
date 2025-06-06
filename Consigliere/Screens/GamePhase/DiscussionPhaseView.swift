import UIKit

final class DiscussionPhaseView: UIView {
    private let titleLabel = UILabel()
    private let timerView = TimerView()
    private let nextButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let nominatedContainerStackView = UIStackView()
    private let nominatedTitleLabel = UILabel()
    private let nominatedPlayersStackView = UIStackView()
    private let noNominationsLabel = UILabel()
    
    private let killedLastNightPlayerIndex: Int?
    private var start = 0


    private var currentPlayerIndex = 0
    private let alivePlayerIndices: [Int]
    var onNextPhase: (() -> Void)?

    init(alivePlayerIndices: [Int], startingPlayerIndex: Int, killedLastNightPlayerIndex: Int?) {
        let rotatedIndices = Self.rotatedAliveIndices(alivePlayerIndices, startingFrom: startingPlayerIndex)
        self.alivePlayerIndices = rotatedIndices
        self.killedLastNightPlayerIndex = killedLastNightPlayerIndex
        super.init(frame: .zero)
        setupView()
        updateUI()
    }
    
    private var isShowingFinalWords: Bool {
        return killedLastNightPlayerIndex != nil && currentPlayerIndex == 0
    }





    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Title label
        titleLabel.text = "Discussion"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Next button
        configureButton(nextButton, title: "Next", color: .systemGray, systemImage: "arrow.right", isTrailing: true)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        // Previous button
        configureButton(previousButton, title: "Previous", color: .systemGray, systemImage: "arrow.left", isTrailing: false)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        
        
        // Конфиг заголовка "Nominated:"
        nominatedTitleLabel.text = "Nominated:"
        nominatedTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nominatedTitleLabel.textColor = .label

        // Конфиг бейджей
        nominatedPlayersStackView.axis = .horizontal
        nominatedPlayersStackView.alignment = .center
        nominatedPlayersStackView.spacing = 8

        // Вертикальный контейнер для заголовка и бейджей
        nominatedContainerStackView.axis = .vertical
        nominatedContainerStackView.spacing = 4
        nominatedContainerStackView.alignment = .leading
        nominatedContainerStackView.translatesAutoresizingMaskIntoConstraints = false

        nominatedContainerStackView.addArrangedSubview(nominatedTitleLabel)
        nominatedContainerStackView.addArrangedSubview(nominatedPlayersStackView)
        addSubview(nominatedContainerStackView)

        // Лейбл для случая без номинантов
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

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timerView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false

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

            nextButton.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 8),
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

    private func updateUI() {
        if isShowingFinalWords {
            timerView.setSpeechLabel(text: "Final words")
            configureButton(nextButton, title: "Next", color: .systemGray, systemImage: "arrow.right", isTrailing: true)
            previousButton.isHidden = true
            return
        }

        let aliveIndex = currentPlayerIndex - (killedLastNightPlayerIndex != nil ? 1 : 0)

        guard aliveIndex >= 0 && aliveIndex < alivePlayerIndices.count else { return }

        let playerIndex = alivePlayerIndices[aliveIndex]
        let playerNumber = playerIndex + 1
        timerView.setSpeechLabel(text: "Player \(playerNumber)")

        let totalCount = alivePlayerIndices.count + (killedLastNightPlayerIndex != nil ? 1 : 0)
        let isLastPlayer = currentPlayerIndex == totalCount - 1
        
        let nextTitle = isLastPlayer ? "Next Phase" : "Next"
        let nextColor = isLastPlayer ? UIColor.systemIndigo : UIColor.systemGray
        configureButton(nextButton, title: nextTitle, color: nextColor, systemImage: "arrow.right", isTrailing: true)

        previousButton.isHidden = currentPlayerIndex == 0
        configureButton(previousButton, title: "Previous", color: .systemGray, systemImage: "arrow.left", isTrailing: false)
    }




    
    func updateNominatedPlayers(_ indices: [Int]?) {
        nominatedPlayersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let hasNominations = indices != nil && !(indices?.isEmpty ?? true)

        nominatedContainerStackView.isHidden = !hasNominations
        noNominationsLabel.isHidden = hasNominations

        guard let indices = indices, !indices.isEmpty else { return }

        for index in indices {
            let badge = NumberBadge()
            badge.setNumber(index + 1)
            nominatedPlayersStackView.addArrangedSubview(badge)
        }
    }
    
    private static func rotatedAliveIndices(_ indices: [Int], startingFrom startIndex: Int) -> [Int] {
        guard !indices.isEmpty else { return [] }

        if let startPosition = indices.firstIndex(where: { $0 >= startIndex }) {
            let head = indices[startPosition..<indices.count]
            let tail = indices[0..<startPosition]
            return Array(head + tail)
        } else {
            return indices
        }
    }





    @objc private func nextTapped() {
        let totalCount = alivePlayerIndices.count + (killedLastNightPlayerIndex != nil ? 1 : 0)
        if currentPlayerIndex < totalCount - 1 {
            currentPlayerIndex += 1
            start = 1
            updateUI()
        } else {
            onNextPhase?()
        }
    }
    
    @objc private func previousTapped() {
        if currentPlayerIndex > 0 {
            currentPlayerIndex -= 1
            updateUI()
        }
    }


}


