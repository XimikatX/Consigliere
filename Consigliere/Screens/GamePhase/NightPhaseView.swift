import UIKit

final class NightPhaseView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let badgeStack = UIStackView()
    private let nextButton = UIButton(type: .system)

    private var alivePlayers: [Player] = []
    private var badgeViews: [NumberBadge] = []
    private var selectedIndex: Int? = nil  

    var onNext: ((Int?) -> Void)?

    init(alivePlayers: [Player]) {
        self.alivePlayers = alivePlayers
        super.init(frame: .zero)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Title
        titleLabel.text = "Night"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center

        // Subtitle
        subtitleLabel.text = "Mafia kills..."
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center

        // Scroll & Stack
        badgeStack.axis = .horizontal
        badgeStack.spacing = 12
        badgeStack.alignment = .center

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(badgeStack)

        // Player badges
        for player in alivePlayers {
            let badge = NumberBadge()
            badge.setNumber(player.index + 1)
            badge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(badgeTapped(_:))))
            badge.tag = player.index  // Сохраняем реальный индекс игрока, а не порядковый
            badgeStack.addArrangedSubview(badge)
            badgeViews.append(badge)
            badge.widthAnchor.constraint(equalToConstant: 28).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }


        // "Miss" badge
        let missBadge = NumberBadge()
        missBadge.setText("Miss")
        missBadge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(badgeTapped(_:))))
        missBadge.tag = -1
        badgeStack.addArrangedSubview(missBadge)
        badgeViews.append(missBadge)
        missBadge.widthAnchor.constraint(equalToConstant: 60).isActive = true
        missBadge.heightAnchor.constraint(equalToConstant: 28).isActive = true


        // Next button
        nextButton.setTitle("Next Phase", for: .normal)
        nextButton.backgroundColor = .systemIndigo
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        nextButton.isEnabled = false
        nextButton.alpha = 0.7
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    private func layoutViews() {
        [titleLabel, subtitleLabel, scrollView, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        badgeStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 44),

            badgeStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            badgeStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            badgeStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            badgeStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            badgeStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            nextButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 24),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20),
            nextButton.widthAnchor.constraint(equalToConstant: 180)
        ])
    }

    @objc private func badgeTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let tappedTag = view.tag
        if tappedTag == -1 {
            selectedIndex = nil
        } else {
            selectedIndex = tappedTag
        }

        updateSelection()
    }


    private func updateSelection() {
        for badge in badgeViews {
            if badge.tag == selectedIndex {
                badge.setSelected(true)
            } else if badge.tag == -1 && selectedIndex == nil {
                badge.setSelected(true)
            } else {
                badge.setSelected(false)
            }
        }

        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }

    @objc private func nextButtonTapped() {
        onNext?(selectedIndex)
    }
}
