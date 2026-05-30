//
//  MainViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let vm = MainDIContainer().makeViewModel()
    private let locationManager = CLLocationManager()
    private var sections: [MainFavoriteBusSection] = []
    private var autoRefreshDisposable: Disposable?
    
    private let segmentControlView: SegmentControlView = {
        let view = SegmentControlView(titles: ["출근길", "퇴근길"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // 최근 업데이트된 시간
    var lastUpdateTimeText = ""
    
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
        super.viewWillAppear(animated)
        setNavi()
        vm.reloadFavorites()
        startAutoRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
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
    }
    private func configure() {
        view.backgroundColor = .systemBackground
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()

        if locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setTableView(){
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 60
        tableView.register(MainFavoriteBusCell.self, forCellReuseIdentifier: MainFavoriteBusCell.cellId)
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
        vm.input.isGoToWork.accept(targetIndex == 0)
        setBottomGuideLbl()
    }
    
    private func setBottomGuideLbl() {
        bottomGuideLbl.text = lastUpdateTimeText
    }

    private func updateLastUpdateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        lastUpdateTimeText = "최근 업데이트 \(formatter.string(from: Date()))"
        setBottomGuideLbl()
    }
    
    private func bind() {
        segmentControlView.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        vm.output.sections
            .drive(onNext: { [weak self] sections in
                guard let self else { return }

                let shouldReload = self.sectionItemIds != sections.itemIds
                self.sections = sections

                if shouldReload {
                    self.tableView.reloadData()
                } else {
                    self.updateVisibleFavoriteCells()
                }
            })
            .disposed(by: disposeBag)

        vm.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                    self?.updateLastUpdateTime()
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func handleRefresh() {
        vm.input.refreshTrigger.accept(())
    }

    private func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshDisposable = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tick in
                self?.vm.advanceArrivalCountdown()

                if (tick + 1).isMultiple(of: 60) {
                    self?.vm.input.refreshTrigger.accept(())
                }
            })
    }

    private func stopAutoRefresh() {
        autoRefreshDisposable?.dispose()
        autoRefreshDisposable = nil
    }

    private var sectionItemIds: [[String]] {
        sections.map { section in
            section.rows.map(\.favorite.id)
        }
    }

    private func updateVisibleFavoriteCells() {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            guard indexPath.section < sections.count,
                  let cell = tableView.cellForRow(at: indexPath) as? MainFavoriteBusCell else {
                return
            }

            configure(cell, with: sections[indexPath.section].rows[indexPath.row])
        }
    }
    
    @objc private func segmentChanged(_ sender: SegmentControlView) {
        setBottomGuideLbl()
        switch sender.selectedIndex {
        case 0:
            vm.input.isGoToWork.accept(true)
        case 1:
            vm.input.isGoToWork.accept(false)
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

        let addFavorite = UIAction(title: "즐겨찾기 추가하기") { [weak self] _ in
            self?.presentSearchViewController()
        }

        let settingMenu = UIMenu(title: "", children: [regionAction, addFavorite])

        let settingButton = UIBarButtonItem(
            image: gearImage,
            menu: settingMenu
        )
        navigationItem.rightBarButtonItem = settingButton
    }
    
    
    private func resetRegion() {
        presentSetRegionViewController()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections.count {
            return 1
        }

        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sections.count {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NextButtonCell.cellId,
                for: indexPath
            ) as! NextButtonCell
            cell.selectionStyle = .none
            return cell
        }

        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MainFavoriteBusCell.cellId,
            for: indexPath
        ) as! MainFavoriteBusCell

        configure(cell, with: row)
        return cell
    }

    private func configure(_ cell: MainFavoriteBusCell, with row: MainFavoriteBusRow) {
        cell.configure(
            busNumber: row.favorite.routeNo,
            busType: row.favorite.routeType,
            arrivalTime: row.arrival?.arrivalTime,
            stationCount: row.arrival?.arrivalAtStationCount
        )
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < sections.count else { return nil }
        return sections[section].stationName
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sections.count {
            presentSearchViewController()
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.section < sections.count else { return nil }

        let favorite = sections[indexPath.section].rows[indexPath.row].favorite
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.vm.removeFavorite(favorite)
            completion(false)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        vm.input.currentLocation.accept(location)
        manager.stopUpdatingLocation()
    }
}

extension MainViewController {
    func presentSearchViewController() {
        let searchVC = SearchViewController(isGoToWork: segmentControlView.selectedIndex == 0)
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func presentSetRegionViewController() {
        let setRegionVC = SetRegionViewController(skipIfAlreadySelected: false)
        navigationController?.pushViewController(setRegionVC, animated: true)
    }
}
