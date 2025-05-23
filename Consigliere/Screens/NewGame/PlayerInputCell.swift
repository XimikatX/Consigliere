import UIKit


class PlayerInputCell: UITableViewCell, UITextFieldDelegate {
    
    static let id = "PlayerInputCell"
    
    var index: Int?
    weak var delegate: PlayerInputCellDelegate?
    
    let numberBadge = NumberBadge()
    
    lazy var nicknameField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Nickname"
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.returnKeyType = .done
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        contentView.addSubview(numberBadge)
        contentView.addSubview(nicknameField)
    }
    
    func constrainSubviews() {
        numberBadge.translatesAutoresizingMaskIntoConstraints = false
        nicknameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            numberBadge.widthAnchor.constraint(equalToConstant: 28),
            numberBadge.heightAnchor.constraint(equalToConstant: 28),
            numberBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            nicknameField.leadingAnchor.constraint(equalTo: numberBadge.trailingAnchor, constant: 12),
            nicknameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nicknameField.centerYAnchor.constraint(equalTo: centerYAnchor),
            nicknameField.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(forIndex index: Int) {
        self.index = index
        numberBadge.setNumber(index + 1)
    }
    
    @objc private func textDidChange() {
        guard let delegate, let index else { return }
        delegate.nicknameFieldTextDidChange(to: nicknameField.text ?? "", for: index)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let delegate, let index else { return true }
        if delegate.nicknameFieldShouldReturn(for: index) {
            textField.resignFirstResponder()
        }
        return false
    }
    
}

protocol PlayerInputCellDelegate : AnyObject {
    func nicknameFieldTextDidChange(to nickname: String, for index: Int)
    func nicknameFieldShouldReturn(for index: Int) -> Bool
}
    
