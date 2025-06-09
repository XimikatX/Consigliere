import UIKit
import Combine

class OngoingGameViewController: UIViewController {
    
    private let viewModel: OngoingGameViewModel
    private var cancellables: Set<AnyCancellable> = []

    private let playerTable: UITableView = {
        let tableView = UITableView()
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.id)
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private var selectedIndexPath: IndexPath?

    



    // MARK: - Init
    
    init(viewModel: OngoingGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bottomSheet = BottomSheetView()

    
    private lazy var bottomSheetVC = BottomSheetViewController(viewModel: viewModel)
    
    private lazy var showRolesButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "eye"),
            style: .plain,
            target: self,
            action: #selector(toggleRolesVisibility)
        )
        button.tintColor = .systemIndigo
        return button
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ongoing Game"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .brandBlue
        
        navigationItem.rightBarButtonItem = showRolesButton

        view.backgroundColor = .systemBackground

        setupBindings()
        setupSubviews()
        constrainSubviews()

        //bottomSheetViewModel.gameState!.phaseState.currentPhase = .initialNight
    }

    // MARK: - Setup

    private func setupBindings() {
        viewModel.$gameState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameState in
                guard let self else { return }
                if gameState == nil {
                    navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }

    private func setupSubviews() {
        view.addSubview(playerTable)
        playerTable.dataSource = self
        playerTable.delegate = self

        bottomSheet.attach(to: view)

        addChild(bottomSheetVC)
        bottomSheet.contentView.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        bottomSheetVC.onContentHeightUpdate = { [weak self] height in
            self?.bottomSheet.updateHeight(to: height)
        }

        bottomSheetVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSheetVC.view.topAnchor.constraint(equalTo: bottomSheet.contentView.topAnchor),
            bottomSheetVC.view.bottomAnchor.constraint(equalTo: bottomSheet.contentView.bottomAnchor),
            bottomSheetVC.view.leadingAnchor.constraint(equalTo: bottomSheet.contentView.leadingAnchor),
            bottomSheetVC.view.trailingAnchor.constraint(equalTo: bottomSheet.contentView.trailingAnchor)
        ])
    }

    private func constrainSubviews() {
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        playerTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 220, right: 0)
    }
}

// MARK: - UITableViewDataSource

extension OngoingGameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerCell.id, for: indexPath
        ) as? PlayerCell else {
            fatalError("Could not dequeue PlayerCell.")
        }

        cell.viewModel = viewModel
        cell.index = indexPath.row

        cell.cancellable = viewModel.$gameState
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.players[indexPath.row] }
            .removeDuplicates()
            .sink { player in
                cell.configure(for: player)
            }

        cell.currentPhaseCancellable = viewModel.$gameState
            .map { $0?.phaseState.currentPhase }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { phase in
                cell.currentPhase = phase
            }


        cell.isExpanded = indexPath == selectedIndexPath

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return indexPath == selectedIndexPath ? 108 : 56
        }
    
    @objc private func toggleRolesVisibility() {
        viewModel.areRolesVisible.toggle()
        
        // Изменим иконку и цвет кнопки
        let imageName = viewModel.areRolesVisible ? "eye.slash" : "eye"
        showRolesButton.image = UIImage(systemName: imageName)
        showRolesButton.tintColor = viewModel.areRolesVisible ? .systemRed : .systemIndigo
        
        // Обновим только видимые ячейки без анимации
        UIView.performWithoutAnimation {
            for indexPath in playerTable.indexPathsForVisibleRows ?? [] {
                if let cell = playerTable.cellForRow(at: indexPath) as? PlayerCell {
                    let player = viewModel.gameState?.players[indexPath.row]
                    cell.configure(for: player!)
                }
            }
        }
    }




}

// MARK: - UITableViewDelegate

extension OngoingGameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsToReload: [IndexPath] = []

        if indexPath == selectedIndexPath {
            indexPathsToReload = [indexPath]
            selectedIndexPath = nil
        } else if let selectedIndexPath {
            indexPathsToReload = [indexPath, selectedIndexPath]
            self.selectedIndexPath = indexPath
        } else {
            indexPathsToReload = [indexPath]
            selectedIndexPath = indexPath
        }

        tableView.reconfigureRows(at: indexPathsToReload)
    }
}
