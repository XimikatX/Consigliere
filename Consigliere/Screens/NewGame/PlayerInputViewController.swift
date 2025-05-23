import UIKit
import Combine

class PlayerInputViewController: UIViewController {
    
    private let viewModel: NewGameViewModel
    
    var cancellables: Set<AnyCancellable> = []
    
    var onCancel: (() -> Void)?
    var onDone: (() -> Void)?
    
    init(viewModel: NewGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.$playerNicknames
            .receive(on: RunLoop.main)
            .map { !$0.contains { $0.isEmpty } }
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var playerTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PlayerInputCell.self, forCellReuseIdentifier: PlayerInputCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 56
        tableView.separatorInset = .zero
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Game"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .generic
        navigationController?.navigationBar.tintColor = .brandBlue
        
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain,
            target: self, action: #selector(onCancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done,
            target: self, action: #selector(onDoneTapped)
        )
        
        setupSubviews()
        constrainSubviews()
    }

    private func setupSubviews() {
        view.addSubview(playerTable)
    }

    private func constrainSubviews() {
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            // this fixes nasty constraint warnings
            playerTable.bottomAnchor.constraint(greaterThanOrEqualTo: view.keyboardLayoutGuide.topAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func onCancelTapped() {
        onCancel?()
    }
    
    @objc private func onDoneTapped() {
        view.endEditing(false)
        onDone?()
    }

}

// MARK: - UITableViewDataSource

extension PlayerInputViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerInputCell.id, for: indexPath)
                as? PlayerInputCell else {
            fatalError("OngoingGameScreenController could not dequeue a PlayerInputCell.")
        }

        cell.delegate = self
        cell.configure(forIndex: indexPath.row)
        cell.nicknameField.text = viewModel.playerNicknames[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlayerInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerInputCell else { return }
        cell.nicknameField.becomeFirstResponder()
    }
}

// MARK: - PlayerInputCellDelegate

extension PlayerInputViewController: PlayerInputCellDelegate {

    func nicknameFieldTextDidChange(to nickname: String, for index: Int) {
        viewModel.setPlayerNickname(nickname, forIndex: index)
    }

    func nicknameFieldShouldReturn(for index: Int) -> Bool {
        guard index + 1 < 10 else { return true }

        let nextIndexPath = IndexPath(row: index + 1, section: 0)
        playerTable.scrollToRow(at: nextIndexPath, at: .none, animated: false)

        if let nextCell = playerTable.cellForRow(at: nextIndexPath) as? PlayerInputCell {
            nextCell.nicknameField.becomeFirstResponder()
        }
        
        return false
    }
    
}
