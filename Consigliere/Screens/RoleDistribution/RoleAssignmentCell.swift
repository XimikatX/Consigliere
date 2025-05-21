//
//  RoleAssignmentCell.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 20/05/2025.
//

import UIKit

class RoleAssignmentCell: UITableViewCell {
    static let id = "RoleAssignmentCell"

    let numberLabel = NumberBadge()
    let nicknameLabel = UILabel()
    let roleSelector = UISegmentedControl(items: Role.allCases.map { $0.rawValue })

    var index: Int = 0
    var roleChanged: ((Int, Role) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        nicknameLabel.font = .systemFont(ofSize: 17)
        nicknameLabel.numberOfLines = 1
        nicknameLabel.lineBreakMode = .byTruncatingTail
        nicknameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [numberLabel, nicknameLabel, roleSelector])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true

        roleSelector.setContentHuggingPriority(.required, for: .horizontal)
        roleSelector.setContentCompressionResistancePriority(.required, for: .horizontal)

        roleSelector.addTarget(self, action: #selector(roleChangedAction), for: .valueChanged)
    }


    @objc private func roleChangedAction() {
        guard let role = Role.allCases[safe: roleSelector.selectedSegmentIndex] else { return }
        roleChanged?(index, role)
    }

    func configure(index: Int, name: String, selectedRole: Role?) {
        self.index = index
        numberLabel.setNumber(index + 1)
        nicknameLabel.text = name
        if let selectedRole, let idx = Role.allCases.firstIndex(of: selectedRole) {
            roleSelector.selectedSegmentIndex = idx
        } else {
            roleSelector.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

