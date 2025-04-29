//
//  PlayerInputCell.swift
//  Consigliere
//
//  Created by Aleksey Boris on 10/04/2025.
//

import UIKit

class PlayerInputCell: UITableViewCell {
    
    static let id = "PlayerInputCell"
    
    // TODO: Move this to a separate view
    // TODO: Fix number 10 label: should use condensed font
    let numberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        let fontSize: CGFloat = 20
        let font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        if let descriptor = font.fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            label.font = font
        }
        return label
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nickname"
        // textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // Should always add subviews to the cell's contentView
        contentView.addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        contentView.addSubview(nicknameTextField)
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nicknameTextField.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            nicknameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nicknameTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 32)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(forIndex index: Int, delegate: UITextFieldDelegate) {
        numberLabel.text = "\(index + 1)"
        nicknameTextField.tag = index
        nicknameTextField.delegate = delegate
        nicknameTextField.returnKeyType = index + 1 < 10 ? .next : .done
    }

}
