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
    private let vm = SearchDIContainer().makeBusStationViewModel()

    private var tableView: UITableView!
    private var items: [BusStationCellPresentable] = []
    
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
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
            make.width.greaterThanOrEqualTo(24)
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
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] text in
                guard let self else { return }
                if text.count > 0 {
                    self.vm.input.searchQuery.accept(text)
                } else {
                    items = []
                    tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: - output
        vm.output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    private func fetch() {
        // 화면 진입 시 필요한 초기 요청 넣을 자리
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
}
