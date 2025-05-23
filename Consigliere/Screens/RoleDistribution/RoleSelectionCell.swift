//
//  RoleAssignmentCell.swift
//  Consigliere
//
//  Created by Yehor Kuzmych on 20/05/2025.
//

import UIKit

class RoleSelectionCell: UITableViewCell {
    static let id = "RoleAssignmentCell"

    var viewModel: NewGameViewModel?
    var index: Int?
    // var roleChanged: ((Int, Role) -> Void)?

    let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
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
        // label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var roleSelector: UISegmentedControl = {
        let selector = UISegmentedControl(items: Role.allCases.map { $0.rawValue })
        selector.setContentHuggingPriority(.required, for: .horizontal)
        selector.setContentCompressionResistancePriority(.required, for: .horizontal)
        selector.addTarget(self, action: #selector(roleChangedAction), for: .valueChanged)
        return selector
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

//        let stack = UIStackView(arrangedSubviews: [numberBadge, nicknameLabel, roleSelector])
//        stack.axis = .horizontal
//        stack.spacing = 12
//        stack.alignment = .center
//        stack.distribution = .fill

//        numberBadge.translatesAutoresizingMaskIntoConstraints = false
//        numberBadge.widthAnchor.constraint(equalToConstant: 28).isActive = true
//        numberBadge.heightAnchor.constraint(equalToConstant: 28).isActive = tru
        setupSubviews()
        constrainSubviews()
    }
    
    func setupSubviews() {
        rowStack.addArrangedSubview(numberBadge)
        numberBadge.setContentHuggingPriority(.required, for: .horizontal)
        rowStack.addArrangedSubview(nicknameLabel)
        rowStack.addArrangedSubview(roleSelector)
        contentView.addSubview(rowStack)
    }
    
    func constrainSubviews() {
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func roleChangedAction() {
        guard let role = Role.allCases[safe: roleSelector.selectedSegmentIndex] else { return }
        guard let index else { return }
        viewModel?.setRole(role, forIndex: index)
    }

    func configure(index: Int, nickname: String, selectedRole: Role?) {
        self.index = index
        numberBadge.setNumber(index + 1)
        nicknameLabel.text = nickname
        if let selectedRole, let idx = Role.allCases.firstIndex(of: selectedRole) {
            roleSelector.selectedSegmentIndex = idx
        } else {
            roleSelector.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
    
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

