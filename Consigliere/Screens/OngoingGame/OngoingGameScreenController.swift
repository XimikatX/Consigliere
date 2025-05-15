//
//  OngoingGameScreenControllerViewController.swift
//  Consigliere
//
//  Created by Aleksey Boris on 16/04/2025.
//

import UIKit
import Combine


class OngoingGameScreenController: UIViewController {
    
    private let viewModel: OngoingGameViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: OngoingGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let playerTable: UITableView = {
        let tableView = UITableView()
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.id)
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private var selectedIndexPath: IndexPath?
    
    private let timerView = TimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ongoing Game"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .brandBlue
        
        view.backgroundColor = .systemBackground
        
        viewModel.$gameState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameState in
                guard let self else { return }
                if gameState == nil {
                    navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
        
        setupSubviews()
        constrainSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(playerTable)
        playerTable.dataSource = self
        playerTable.delegate = self
    }
    
    private func constrainSubviews() {
        playerTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerTable)

        NSLayoutConstraint.activate([
            playerTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        playerTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 220, right: 0)

        timerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerView)

        NSLayoutConstraint.activate([
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            timerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        view.bringSubviewToFront(timerView)
    }

    
}

extension OngoingGameScreenController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.id, for: indexPath)
                as? PlayerCell
        else {
            fatalError("OngoingGameScreenController could not dequeue a PlayerCell.")
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
        cell.isExpanded = indexPath == selectedIndexPath

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == selectedIndexPath ? 108 : 56
    }
    
}

extension OngoingGameScreenController: UITableViewDelegate {
    
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
