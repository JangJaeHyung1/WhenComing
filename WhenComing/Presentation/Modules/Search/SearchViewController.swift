//
//  SearchViewController.swift
//  WhenComing
//
//  Created by jh on 10/30/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let vm = SearchDIContainer().makeSearchViewModel()

    private var tableView: UITableView!
    
    // 헤더 컨테이너
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        return v
    }()

    // 뒤로가기 버튼
    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 4
        config.baseForegroundColor = .label
        btn.configuration = config
        btn.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return btn
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "역 이름 또는 버스 번호 검색"
        sb.searchBarStyle = .minimal
        sb.backgroundImage = UIImage()
        sb.becomeFirstResponder()
        sb.backgroundColor = .clear
        sb.searchTextField.layer.borderColor = UIColor.clear.cgColor
        sb.searchTextField.backgroundColor = .clear
        sb.searchTextField.clearButtonMode = .whileEditing
        return sb
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController {
    private func setUp() {
        configure()
        setTableView()
        addViews()
        setConstraints()
        bind()
        fetch()
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
    }

    private func setTableView() {
        tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .onDrag
    }

    private func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
    }

    private func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(32)
        }

        searchBar.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func bind() {
        // MARK: - input
        // 검색어 변경 → 뷰모델로 전달
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] text in
                guard let self else { return }
                if text.count > 0 {
                    self.vm.input.searchQuery.accept(text)
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: - output
        vm.output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        vm.output.isFetchMore
            .drive(onNext: { [weak self] isLoadingMore in
                guard let self else { return }
                if isLoadingMore {
                    let footer = UIActivityIndicatorView()
                    footer.startAnimating()
                    footer.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 44)
                    self.tableView.tableFooterView = footer
                } else {
                    self.tableView.tableFooterView = nil
                }
            })
            .disposed(by: disposeBag)
        
        vm.output.items
            .drive(
                tableView.rx.items(
                    cellIdentifier: "cell",
                    cellType: UITableViewCell.self
                )
            ) { row, item, cell in

                switch item {
                case .route(let route):
                    cell.textLabel?.text = "\(route.routeNo) \(route.routeType)"
                case .station(let station):
                    if let stationNum = station.stationNumber {
                        cell.textLabel?.text = "\(station.name) (\(stationNum)) 버스역"
                    } else {
                        cell.textLabel?.text = "\(station.name) 버스역"
                    }
                    
                }
            }
            .disposed(by: disposeBag)
        
        // 마지막 셀 기준으로 3개 전 셀이 화면에 보일 때 트리거 (throttled)
        tableView.rx.willDisplayCell
//            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_, indexPath) in
                guard let self else { return }
                let totalRows = self.tableView.numberOfRows(inSection: indexPath.section)
                if indexPath.row == totalRows - 5 {
                    self.vm.loadNextStationsPage()
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SearchItem.self)
            .subscribe(onNext:{ [weak self] item in
                guard let self else { return }
                switch item {
                case .route(let route):
                    print("\(route)")
                case .station(let station):
                    self.nextVC(busStation: station)
                }
            })
            .disposed(by: disposeBag)
    }

    private func fetch() {
        // 화면 진입 시 필요한 초기 요청 넣을 자리
    }
}


// MARK: - nextVC

extension SearchViewController {
    func nextVC(busStation: BusStationEntity) {
        let nextVC = BusStationViewController(busStation: busStation)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
