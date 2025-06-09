//
//  NumberBadge.swift
//  Consigliere
//
//  Created by Aleksey Boris on 18/04/2025.
//

import UIKit

class NumberBadge: UIView {

    let label: UILabel = {
        let label = UILabel()
        let fontSize: CGFloat = 19
        var font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        if let descriptor = font.fontDescriptor.withDesign(.rounded) {
            label.font = .init(descriptor: descriptor, size: fontSize)
        } else {
            label.font = font
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private var isMiss: Bool = false

    func setNumber(_ number: Int?) {
        guard let number, (1...10).contains(number) else { return }
        label.text = "\(number)"
        label.transform = number == 10 ? .init(scaleX: 0.85, y: 1) : .identity
        isMiss = false
        invalidateIntrinsicContentSize()
    }

    func setText(_ text: String) {
        label.text = text
        isMiss = true
        invalidateIntrinsicContentSize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = R.Colors.Label.primary
        clipsToBounds = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 6
    }

    override var intrinsicContentSize: CGSize {
        return isMiss
            ? CGSize(width: 60, height: 28)
            : CGSize(width: 28, height: 28)
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .systemRed : R.Colors.Label.primary
    }

    func setGray(_ gray: Bool) {
        backgroundColor = gray ? .systemGray4 : R.Colors.Label.primary
        label.textColor = gray ? .systemGray : .white
    }
}
