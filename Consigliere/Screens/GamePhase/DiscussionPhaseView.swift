import UIKit

final class DiscussionPhaseView: UIView {

    private let titleLabel = UILabel()
    private let timerView = TimerView()
    private let nextButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    
    private var currentPlayerIndex = 0
    private let totalPlayers: Int
    var onNextPhase: (() -> Void)?

    init(totalPlayers: Int) {
        self.totalPlayers = totalPlayers
        super.init(frame: .zero)
        setupView()
        updateUI()
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

            timerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
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
        timerView.setSpeechLabel(text: "Player \(currentPlayerIndex + 1)")

        let isLastPlayer = currentPlayerIndex == totalPlayers - 1
        let nextTitle = isLastPlayer ? "Next Phase" : "Next"
        let nextColor = isLastPlayer ? UIColor.systemIndigo : UIColor.systemGray

        configureButton(nextButton, title: nextTitle, color: nextColor, systemImage: "arrow.right", isTrailing: true)

        previousButton.isHidden = currentPlayerIndex == 0
        configureButton(previousButton, title: "Previous", color: .systemGray, systemImage: "arrow.left", isTrailing: false)
    }

    @objc private func nextTapped() {
        if currentPlayerIndex < totalPlayers - 1 {
            currentPlayerIndex += 1
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
