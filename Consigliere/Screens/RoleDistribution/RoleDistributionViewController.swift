import UIKit

class RoleDistributionViewController: UIViewController {

    private let tableView = UITableView()
    var playerNames: [String]
    private var selectedRoles: [Role?]

    init(playerNames: [String]) {
        self.playerNames = playerNames
        self.selectedRoles = Array(repeating: nil, count: playerNames.count)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Role Distribution"
        view.backgroundColor = .systemBackground

        setupNavigation()
        setupTableView()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .done,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .systemIndigo

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Start",
            style: .done,
            target: self,
            action: #selector(startTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RoleAssignmentCell.self, forCellReuseIdentifier: RoleAssignmentCell.id)
        tableView.dataSource = self
        tableView.rowHeight = 56
        tableView.separatorInset = .zero


        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func startTapped() {
        let validPlayers = zip(playerNames, selectedRoles).enumerated().compactMap { index, pair -> Player? in
            guard let role = pair.1 else { return nil }
            return Player(index: index, nickname: pair.0, role: role)
        }

        let gameStateRepository = UserDefaultsGameStateRepository()
        let viewModel = OngoingGameViewModel(gameStateRepository: gameStateRepository)
        let ongoingGameScreenController = OngoingGameScreenController(viewModel: viewModel)
        (navigationController?.presentingViewController as? UINavigationController)?
            .pushViewController(ongoingGameScreenController, animated: true)
        dismiss(animated: true)
    }

    private func validateRoles() {
        let counts = Dictionary(grouping: selectedRoles.compactMap { $0 }, by: { $0 }).mapValues { $0.count }

        let isValid = counts[.citizen] == 6 &&
                      counts[.sheriff] == 1 &&
                      counts[.don] == 1 &&
                      counts[.mafia] == 2 &&
                      selectedRoles.allSatisfy { $0 != nil }

        navigationItem.rightBarButtonItem?.isEnabled = isValid
        navigationItem.rightBarButtonItem?.tintColor = isValid ? .systemIndigo : .systemGray
    }
}

// MARK: - UITableViewDataSource
extension RoleDistributionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoleAssignmentCell.id, for: indexPath) as? RoleAssignmentCell else {
            fatalError("Unable to dequeue RoleAssignmentCell")
        }

        let role = selectedRoles[indexPath.row]
        cell.configure(index: indexPath.row, name: playerNames[indexPath.row], selectedRole: role)
        cell.roleChanged = { [weak self] index, newRole in
            self?.selectedRoles[index] = newRole
            self?.validateRoles()
        }

        return cell
    }
}
