import UIKit

class BottomSheetView: UIView {
    
    enum State {
        case expanded
        case collapsed
    }

    private let handleView = UIView()
    private let contentContainer = UIView()

    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var currentState: State = .collapsed

    private var topConstraint: NSLayoutConstraint!
    private var collapsedY: CGFloat = 0
    private var expandedY: CGFloat = 0
    private var lastPanTranslation: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupPanGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        handleView.backgroundColor = .systemGray3
        handleView.layer.cornerRadius = 3
        handleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(handleView)

        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 6)
        ])

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 8),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = gesture.translation(in: superview)

        switch gesture.state {
        case .changed:
            let newConstant = topConstraint.constant + translation.y
            topConstraint.constant = min(max(newConstant, expandedY), collapsedY)
            gesture.setTranslation(.zero, in: superview)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: superview).y
            let shouldExpand = velocity < 0
            animate(to: shouldExpand ? .expanded : .collapsed)
        default:
            break
        }
    }

    func attach(to view: UIView, initialState: State = .collapsed) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        collapsedY = view.bounds.height - 110
        expandedY = view.bounds.height / 1.8

        topConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: collapsedY)

        NSLayoutConstraint.activate([
            topConstraint,
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightAnchor.constraint(equalToConstant: view.bounds.height) 
        ])

        view.layoutIfNeeded()
        animate(to: initialState, animated: false)
    }

    func animate(to state: State, animated: Bool = true) {
        guard let superview = superview else { return }

        currentState = state
        topConstraint.constant = (state == .expanded) ? expandedY : collapsedY

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                superview.layoutIfNeeded()
            }
        } else {
            superview.layoutIfNeeded()
        }
    }

    var contentView: UIView {
        return contentContainer
    }
}
