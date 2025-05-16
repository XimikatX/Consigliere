//
//  FoulCountControl.swift
//  Consigliere
//
//  Created by Aleksey Boris on 11/05/2025.
//

import UIKit

class FoulCountControl: UIView {
    
    var maxFoulCount: Int = 3 {
        didSet {
            if foulCount > maxFoulCount { foulCount = maxFoulCount }
        }
    }
    
    var onPlusButtonTapped: (() -> Void)?
    var onMinusButtonTapped: (() -> Void)?
    
    var foulCount: Int = 0 {
        didSet {
            if foulCount < 0 { foulCount = 0 }
            if foulCount > maxFoulCount { foulCount = maxFoulCount }
            minusButton.isEnabled = foulCount > 0
            textLabel.text = "Fouls: \(foulCount)"
            plusButton.isEnabled = foulCount < maxFoulCount
        }
    }
    
    let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .brandBlue
        return button
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "Fouls: 0"
        label.textColor = .brandBlue
        label.numberOfLines = 1
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .brandBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .ghostWhite
        layer.cornerRadius = 8
        
        setupSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(minusButton)
        minusButton.addAction(.init(title: "") { [weak self] _ in
            self?.onMinusButtonTapped?()
        }, for: .touchUpInside)
        addSubview(textLabel)
        // textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(plusButton)
        plusButton.addAction(.init(title: "") { [weak self] _ in
            self?.onPlusButtonTapped?()
        }, for: .touchUpInside)
    }
    
    private lazy var staticConstraints = [
        minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
        minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        minusButton.widthAnchor.constraint(equalToConstant: 36),
        minusButton.heightAnchor.constraint(equalToConstant: 36),
        
        textLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 4),
        textLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -4),
        textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        
        plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        plusButton.widthAnchor.constraint(equalToConstant: 36),
        plusButton.heightAnchor.constraint(equalToConstant: 36),
    ]
    
    private func constrainSubviews() {
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(staticConstraints)
    }

}
