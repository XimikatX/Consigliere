import UIKit
import Combine

class RoleSelectionViewController: UIViewController {

    private let viewModel: NewGameViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var playerTable: UITableView = {
        let tableView = UITableView()
        tableView.register(RoleSelectionCell.self, forCellReuseIdentifier: RoleSelectionCell.id)
        tableView.dataSource = self
        tableView.rowHeight = 56
        tableView.separatorInset = .zero
        return tableView
    }()

    var onStartGame: (() -> Void)?
    
    init(viewModel: NewGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.$selectedRoles
            .receive(on: RunLoop.main)
            .sink { [weak self] roles in
                self?.validateRoles(roles)
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Role Selection"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .brandBlue
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Start", style: .done,
            target: self, action: #selector(onStartTapped)
        )
        
        setupSubviews()
        constrainSubview()
    }

    private func setupSubviews() {
        view.addSubview(playerTable)
    }
    
    private func constrainSubview() {
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func onStartTapped() {
        onStartGame?()
    }

    private func validateRoles(_ roles: [Role?]) {
        let counts = Dictionary(grouping: roles.compactMap { $0 }, by: { $0 }).mapValues { $0.count }

        let isValid = counts[.citizen] == 6 &&
                      counts[.sheriff] == 1 &&
                      counts[.don] == 1 &&
                      counts[.mafia] == 2 &&
        viewModel.selectedRoles.allSatisfy { $0 != nil }
        
        navigationItem.rightBarButtonItem?.isEnabled = isValid
        // navigationItem.rightBarButtonItem?.tintColor = isValid ? .systemIndigo : .systemGray
    }
}

// MARK: - UITableViewDataSource
extension RoleSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playerNicknames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoleSelectionCell.id, for: indexPath) as? RoleSelectionCell else {
            fatalError("Unable to dequeue RoleAssignmentCell")
        }

        let role = viewModel.selectedRoles[indexPath.row]
        cell.configure(index: indexPath.row, nickname: viewModel.playerNicknames[indexPath.row], selectedRole: role)
        cell.viewModel = viewModel

        return cell
    }
}
