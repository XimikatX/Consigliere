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
        let fontSize: CGFloat = 20
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

    func setNumber(_ number: Int?) {
        guard let number, (1...10).contains(number) else { return }
        label.text = "\(number)"
        label.transform = number == 10 ? .init(scaleX: 0.85, y: 1) : .identity
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .black
        clipsToBounds = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been    implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 6
    }

}
