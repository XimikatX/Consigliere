//
//  PlayerCell.swift
//  Consigliere
//
//  Created by Aleksey Boris on 17/04/2025.
//

import UIKit
import Combine


class PlayerCell: UITableViewCell {

    static let id = "PlayerCell"
    
    var viewModel: OngoingGameViewModel?
    var index: Int?
    var cancellable: AnyCancellable?
    
    var isExpanded: Bool = false {
        didSet {
            bottomRowScrollView.isHidden = !isExpanded
            if isExpanded {
                bottomRowScrollView.setContentOffset(.zero, animated: false)
            }
            updateNominateButtonAppearance()
        }
    }

    
    let topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
    let nicknameWithAccessories: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fill
        stack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return stack
    }()
    
    let numberBadge = NumberBadge()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = R.Colors.Label.primary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let foulsIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .brandBlue
        return imageView
    }()
    
    let techFoulIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "foul.1")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .imperialRed
        return imageView
    }()
    
    let nominateButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.forPlayerCell()
        config.image = UIImage(systemName: "hammer.fill")
        button.configuration = config
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let bottomRowScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let bottomRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.forPlayerCell()
        config.image = UIImage(systemName: "person.crop.circle.fill")
        config.title = "Profile"
        button.configuration = config
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    lazy var foulsControl: FoulCountControl = {
        let control = FoulCountControl()
        control.onMinusButtonTapped = { [weak self] in
            guard let self, let index else { return }
            viewModel?.removeFoulFromPlayer(at: index)
        }
        control.onPlusButtonTapped = { [weak self] in
            guard let self, let index else { return }
            viewModel?.assignFoulToPlayer(at: index)
        }
        return control
    }()
    
    lazy var muteButton: UIButton = {
        var config = UIButton.Configuration.forPlayerCell()
        config.image = UIImage(systemName: "microphone.slash.fill")
        config.title = "Mute"
        let button = UIButton(type: .system)
        button.configuration = config
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.configurationUpdateHandler = { button in
            var config = button.configuration!
            if button.state.contains(.selected) {
                config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                    return .brandBlue
                }
                config.baseForegroundColor = .white
            } else {
                config.background.backgroundColorTransformer = nil
                config.baseForegroundColor = .brandBlue
            }
            button.configuration = config
        }
        button.addAction(
            UIAction(title: "") { [weak self] _ in
                guard let self, let index else { return }
                viewModel?.toggleMuteForPlayer(at: index)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var techFoulButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.forPlayerCell()
        config.image = UIImage(systemName: "exclamationmark.circle.fill")
        config.title = "Tech. Foul"
        button.configuration = config
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.configurationUpdateHandler = { button in
            var config = button.configuration!
            if button.state.contains(.selected) {
                config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                    return .imperialRed
                }
                config.baseForegroundColor = .white
            } else {
                config.background.backgroundColorTransformer = nil
                config.baseForegroundColor = .brandBlue
            }
            button.configuration = config
        }
        button.addAction(
            UIAction(title: "") { [weak self] _ in
                guard let self, let index else { return }
                viewModel?.toggleTechFoulForPlayer(at: index)
            }, for: .touchUpInside)
        return button
    }()
    
    lazy var disqualifyButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.forPlayerCell()
        config.image = UIImage(systemName: "door.right.hand.open")
        config.title = "Disqualify"
        config.baseForegroundColor = .imperialRed
        button.configuration = config
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    var currentPhase: GamePhase? {
        didSet {
            if currentPhase != .discussion {
                resetNomination()
            }
            updateNominateButtonAppearance()
        }
    }
    
    var currentPhaseCancellable: AnyCancellable?
    
    
    private var isNominated: Bool = false

    func resetNomination() {
        isNominated = false
        updateNominateButtonAppearance()
    }


    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        // bottomRowScrollView.isHidden = true
     
        setupSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func setupSubviews() {
        contentView.addSubview(topRowStack)
        topRowStack.addArrangedSubview(nicknameWithAccessories)
        nicknameWithAccessories.addArrangedSubview(numberBadge)
        nicknameWithAccessories.setCustomSpacing(12, after: numberBadge)
        nicknameWithAccessories.addArrangedSubview(nicknameLabel)
        nicknameWithAccessories.setCustomSpacing(8, after: nicknameLabel)
        nicknameWithAccessories.addArrangedSubview(foulsIcon)
        nicknameWithAccessories.setCustomSpacing(4, after: foulsIcon)
        nicknameWithAccessories.addArrangedSubview(techFoulIcon)
        topRowStack.addArrangedSubview(nominateButton)
        
        nominateButton.addAction(
            UIAction { [weak self] _ in
                guard let self = self, let index = self.index else { return }
                guard self.currentPhase == .discussion else { return }

                if !self.isNominated {
                    self.isNominated = true
                    self.updateNominateButtonAppearance()
                    print("Player nominated: index = \(index), nickname = \(self.nicknameLabel.text ?? "unknown")")
                }
            }, for: .touchUpInside)

        
        contentView.addSubview(bottomRowScrollView)
        bottomRowScrollView.addSubview(bottomRowStack)
        for view in [profileButton, foulsControl, muteButton, techFoulButton, disqualifyButton] {
            bottomRowStack.addArrangedSubview(view)
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }
    
    private lazy var staticConstraints = [
        topRowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
        topRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        topRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        topRowStack.heightAnchor.constraint(equalToConstant: 40),
        
        bottomRowScrollView.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 8),
        bottomRowScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        bottomRowScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        bottomRowScrollView.heightAnchor.constraint(equalToConstant: 44),
        
        bottomRowStack.heightAnchor.constraint(equalTo: bottomRowScrollView.heightAnchor),
        bottomRowStack.topAnchor.constraint(equalTo: bottomRowScrollView.topAnchor),
        bottomRowStack.bottomAnchor.constraint(equalTo: bottomRowScrollView.bottomAnchor),
        bottomRowStack.leadingAnchor.constraint(equalTo: bottomRowScrollView.leadingAnchor, constant: 16),
        bottomRowStack.trailingAnchor.constraint(equalTo: bottomRowScrollView.trailingAnchor, constant: -16),
    ]
    
    private func constrainSubviews() {
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        bottomRowScrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomRowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(staticConstraints)
    }
    
    func configure(for player: Player) {
        numberBadge.setNumber(player.index + 1)
        nicknameLabel.text = player.nickname 
        if player.foulsCount > 0 {
            foulsIcon.isHidden = false
            foulsIcon.image = UIImage(named: "foul.\(player.foulsCount)")?.withRenderingMode(.alwaysTemplate)
        } else {
            foulsIcon.isHidden = true
        }
        techFoulIcon.isHidden = !player.hasTechFoul
        foulsControl.foulCount = player.foulsCount
        muteButton.isEnabled = player.foulsCount == 3
        muteButton.isSelected = player.isMuted
        techFoulButton.isSelected = player.hasTechFoul
    }
    
    func updateNominateButtonAppearance() {
        let isDiscussion = currentPhase == .discussion

        nominateButton.isEnabled = isDiscussion && !isNominated

        var config = nominateButton.configuration ?? UIButton.Configuration.filled()
        if isNominated {
            
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .systemRed
            config.title = "Nominated"

            
            if let hammerImage = UIImage(systemName: "hammer.fill") {
                let flipped = hammerImage.withHorizontallyFlippedOrientation()
                config.image = flipped.withTintColor(.red, renderingMode: .alwaysOriginal)
            }
        } else {
            
            config.baseForegroundColor = isDiscussion ? .systemIndigo : .systemGray2
            config.baseBackgroundColor = .ghostWhite
            config.title = isDiscussion ? "Nominate" : ""
            config.image = UIImage(systemName: "hammer.fill")?.withTintColor(isDiscussion ? .systemIndigo : .systemGray2, renderingMode: .alwaysOriginal)
        }

        nominateButton.configuration = config
    }


    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        currentPhaseCancellable?.cancel()
        cancellable = nil
        currentPhaseCancellable = nil
    }

    
}

extension UIButton.Configuration {
    
    static func forPlayerCell() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .brandBlue
        config.baseBackgroundColor = .ghostWhite
        config.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.imagePadding = 4
        config.cornerStyle = .fixed
        config.preferredSymbolConfigurationForImage =
            .init(pointSize: 17, weight: .regular, scale: .medium)
        config.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }
        return config
    }
    
}
