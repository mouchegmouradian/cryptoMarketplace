//
//  MarketViewController.swift
//  CryptoMarketplace
//

import UIKit
import RxSwift
import RxCocoa

class MarketViewController: UIViewController {
    // TODO: inject view model into view controller
    private let viewModel = MarketViewModel(service: MarketService())

    private let disposeBag = DisposeBag()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""

        return searchController
    }()
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false

        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = false
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.bounces = false

        tv.layer.masksToBounds = true

        tv.register(MarketItemCell.self, forCellReuseIdentifier: MarketItemCell.identifier)

        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        setupUI()
        setupRx()

        viewModel.viewDidLoad()
    }
}

// MARK: - Private

private extension MarketViewController {
    func setupUI() {
        view.backgroundColor = .white

        view.addSubview(tableView)

        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func setupRx() {
        bindTableData()
        bindSearchController()
    }

    func bindTableData() {
        viewModel.items.bind(to: tableView.rx.items(
            cellIdentifier: MarketItemCell.identifier,
            cellType: MarketItemCell.self)
        ) { row, item, cell in
            cell.setup(data: item)
        }.disposed(by: disposeBag)

        tableView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (cell, indexPath) in
                guard let marketItemCell = cell as? MarketItemCell else { return }
                marketItemCell.drawShadows()
             })
            .disposed(by: disposeBag)
    }

    func bindSearchController() {
        searchController.searchBar
            .rx.text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                viewModel.query.onNext(query)
            })
            .disposed(by: disposeBag)
    }
}
