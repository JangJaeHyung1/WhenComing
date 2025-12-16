//
//  MainViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {
    
    enum SortType {
        case nearestStation   // 가까운역순
        case arrivalTime      // 도착순
    }

    private var currentSortType: SortType = .nearestStation
    
    private let segmentControlView: SegmentControlView = {
        let view = SegmentControlView(titles: ["출근길", "퇴근길"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // 최근 업데이트된 시간
    var lastUpdateTimeText = "최근 업데이트 15시 32분"
    
    private let bottomGuideLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
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
    override func viewWillAppear(_ animated: Bool) {
        setNavi()
    }
}



extension MainViewController {
    private func setUp() {
        configure()
        setTableView()
        setNavi()
        addViews()
        setConstraints()
        bind()
        updateSegmentForCurrentTime()
        fetch()
    }
    private func configure() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetch() {
        
    }

    private func setTableView(){
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(NextButtonCell.self, forCellReuseIdentifier: NextButtonCell.cellId)
        
        tableView.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        refreshControl.transform = .init(scaleX: 0.75, y: 0.75)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
    /// 03:00 ≤ now < 15:00  => 출근(0)
    /// 15:00 ≤ now < 03:00 => 퇴근(1)
    private func updateSegmentForCurrentTime() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let isCommuteTime = (hour >= 3 && hour < 15)
        let targetIndex = isCommuteTime ? 0 : 1
        segmentControlView.select(index: targetIndex, animated: false)
        setBottomGuideLbl()
    }
    
    private func setBottomGuideLbl() {
        bottomGuideLbl.text = lastUpdateTimeText
    }
    
    private func bind() {
        segmentControlView.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func handleRefresh() {
        fetch()
        // TODO: 1초뒤가 아니라 비동기 리턴값 받으면 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func segmentChanged(_ sender: SegmentControlView) {
        setBottomGuideLbl()
        switch sender.selectedIndex {
        case 0:
            // 출근길 탭 선택 시 처리
            print("출근길 탭 선택")
        case 1:
            // 퇴근길 탭 선택 시 처리
            print("퇴근길 탭 선택")
        default:
            break
        }
    }
    
    private func setNavi() {
        self.navigationItem.title = "내 출퇴근 버스"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let gearImage = UIImage(systemName: "gearshape", withConfiguration: config)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let regionAction = UIAction(title: "지역 재설정") { [weak self] _ in
            self?.resetRegion()
        }

        let sortTitle: String
        switch currentSortType {
        case .nearestStation:
            sortTitle = "도착순으로 정렬"
        case .arrivalTime:
            sortTitle = "가까운역순으로 정렬"
        }

        let sortAction = UIAction(title: sortTitle) { [weak self] _ in
            self?.toggleSortType()
        }
        
        let addFavorite = UIAction(title: "즐겨찾기 추가하기") { [weak self] _ in
            self?.presentSearchViewController()
        }

        let settingMenu = UIMenu(title: "", children: [regionAction, sortAction, addFavorite])

        let settingButton = UIBarButtonItem(
            image: gearImage,
            menu: settingMenu
        )
        navigationItem.rightBarButtonItem = settingButton
    }
    
    
    private func resetRegion() {
        presentSetRegionViewController()
    }

    private func toggleSortType() {
        currentSortType = (currentSortType == .nearestStation) ? .arrivalTime : .nearestStation
        // TODO: currentSortType 기준으로 데이터 정렬 후 tableView.reloadData()
        print("현재 정렬: \(currentSortType == .nearestStation ? "가까운역순" : "도착순")")
    }

    private func openFeedback() {
        // TODO: 인앱 피드백 화면 푸시 등
        print("피드백 남기기 선택됨")
    }
    
    private func addViews() {
        view.addSubview(segmentControlView)
        view.addSubview(tableView)
        view.addSubview(bottomGuideLbl)
    }
    
    private func setConstraints() {
        
        segmentControlView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentControlView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomGuideLbl.snp.top).offset(-16)
        }
        
        bottomGuideLbl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastIndex(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NextButtonCell.cellId, for: indexPath) as! NextButtonCell
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Row \(indexPath.row)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLastIndex(indexPath) {
            presentSearchViewController()
        } else {
            
        }
    }
    
    private func isLastIndex(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
    
}

extension MainViewController {
    func presentSearchViewController() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func presentSetRegionViewController() {
        let setRegionVC = SetRegionViewController(skipIfAlreadySelected: false)
        navigationController?.pushViewController(setRegionVC, animated: true)
    }
}
