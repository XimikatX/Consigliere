import UIKit

protocol PlayerInputCellDelegate: AnyObject {
    func playerInputCell(_ cell: PlayerInputCell, didChangeText text: String)
}

class PlayerInputCell: UITableViewCell {
    
    static let id = "PlayerInputCell"
    
    weak var delegate: PlayerInputCellDelegate?
    
    let numberBadge = NumberBadge()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nickname"
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(numberBadge)
        numberBadge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            numberBadge.widthAnchor.constraint(equalToConstant: 28),
            numberBadge.heightAnchor.constraint(equalToConstant: 28),
            numberBadge.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        contentView.addSubview(nicknameTextField)
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nicknameTextField.leadingAnchor.constraint(equalTo: numberBadge.trailingAnchor, constant: 12),
            nicknameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nicknameTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        nicknameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(forIndex index: Int, delegate: UITextFieldDelegate & PlayerInputCellDelegate) {
        numberBadge.setNumber(index + 1)
        nicknameTextField.tag = index
        nicknameTextField.delegate = delegate
        self.delegate = delegate
        nicknameTextField.returnKeyType = index + 1 < 10 ? .next : .done
    }
    
    @objc private func textDidChange() {
        delegate?.playerInputCell(self, didChangeText: nicknameTextField.text ?? "")
    }
}
