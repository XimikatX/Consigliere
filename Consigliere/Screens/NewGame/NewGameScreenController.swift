import UIKit

class NewGameScreenController: UIViewController {
    
    private let playerTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(PlayerInputCell.self, forCellReuseIdentifier: PlayerInputCell.id)
        return table
    }()
    
    private var currentPlayerNames: [String] = Array(repeating: "", count: 10)

    override func viewDidLoad() {
        super.viewDidLoad()
        

        title = "New Game"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .done,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemIndigo
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        
        configurePlayerTable()
        updateDoneButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if DEBUG
        if currentPlayerNames.allSatisfy({ $0.isEmpty }) {
            let animalNames = ["Tiger", "Elephantrrrrrrrrrrrrrrrrrrrrrrr", "Lion", "Zebra", "Giraffe", "Panda", "Wolf", "Koala", "Bear", "Fox"]
            let roleDistributionVC = RoleDistributionViewController(playerNames: animalNames)
            navigationController?.pushViewController(roleDistributionVC, animated: true)
        }
        #endif
    }


    private func configurePlayerTable() {
        view.addSubview(playerTable)
        playerTable.dataSource = self
        playerTable.delegate = self
        playerTable.rowHeight = 56
        playerTable.separatorInset = .zero

        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneTapped() {
        let roleDistributionVC = RoleDistributionViewController(playerNames: currentPlayerNames)
        roleDistributionVC.playerNames = currentPlayerNames
        navigationController?.pushViewController(roleDistributionVC, animated: true)
    }

    private func updateDoneButtonState() {
        let allFilled = currentPlayerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        navigationItem.rightBarButtonItem?.isEnabled = allFilled
        navigationItem.rightBarButtonItem?.tintColor = allFilled ? .systemIndigo : .systemGray
    }
}

// MARK: - UITableViewDataSource

extension NewGameScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerInputCell.id, for: indexPath) as? PlayerInputCell else {
            fatalError("Could not dequeue PlayerInputCell.")
        }

        cell.configure(forIndex: indexPath.row, delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewGameScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerInputCell else { return }
        cell.nicknameTextField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate & PlayerInputCellDelegate

extension NewGameScreenController: UITextFieldDelegate, PlayerInputCellDelegate {
    
    func playerInputCell(_ cell: PlayerInputCell, didChangeText text: String) {
        let row = cell.nicknameTextField.tag
        currentPlayerNames[row] = text.trimmingCharacters(in: .whitespacesAndNewlines)
        updateDoneButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let row = textField.tag
        let nextRow = row + 1
        guard nextRow < 10 else {
            textField.resignFirstResponder()
            return true
        }

        let nextIndexPath = IndexPath(row: nextRow, section: 0)
        playerTable.scrollToRow(at: nextIndexPath, at: .none, animated: true)

        if let nextCell = playerTable.cellForRow(at: nextIndexPath) as? PlayerInputCell {
            nextCell.nicknameTextField.becomeFirstResponder()
        }

        return true
    }
}
