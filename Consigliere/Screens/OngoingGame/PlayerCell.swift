//
//  PlayerCell.swift
//  Consigliere
//
//  Created by Aleksey Boris on 17/04/2025.
//

import UIKit

class PlayerCell: UITableViewCell {

    static let id = "PlayerCell"
    
    var isExpanded: Bool = false {
        didSet {
            button.isHidden = !isExpanded
        }
    }
    
    let numberBadge = NumberBadge()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let topStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = {
            var configuration = UIButton.Configuration.gray()
            configuration.title = "Directions"
            configuration.cornerStyle = .medium
            // configuration.buttonSize = .small
            configuration.image = UIImage(named: "foul.1")?
                .applyingSymbolConfiguration(.init(weight: .semibold))
            configuration.imagePlacement = .top
            // configuration.imagePadding = 4.0
            return configuration
        }()
        // button.tintColor = .systemIndigo
        button.isHidden = true
        button.tintColor = .red
        return button
    }()
    
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
     
        addViews()
        constrainViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        contentView.addSubview(mainStack)
        mainStack.addArrangedSubview(topStack)
        mainStack.addArrangedSubview(button)
        topStack.addArrangedSubview(numberBadge)
        topStack.addArrangedSubview(nicknameLabel)
    }
    
    private func constrainViews() {
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // nicknameLabel.heightAnchor.constraint(equalToConstant: 28),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // button.heightAnchor.constraint(equalToConstant: 50),
            numberBadge.widthAnchor.constraint(equalToConstant: 26),
            numberBadge.heightAnchor.constraint(equalToConstant: 26),
        ])
        
    }
    
    func configure(index: Int, nickname: String) {
        nicknameLabel.text = nickname
        numberBadge.setNumber(index + 1)
    }
    
}
