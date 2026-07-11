//
//  BusStationViewController.swift
//  WhenComing
//
//  Created by jh on 11/22/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MapKit

class BusStationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()

    var busStation: BusStationEntity
    private let vm: BusStationViewModel
    private var autoRefreshDisposable: Disposable?
    // 헤더 컨테이너
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        return v
    }()

    private let mapView: MKMapView = {
        let mv = MKMapView()
        mv.isRotateEnabled = false
        mv.isPitchEnabled = false
        mv.showsCompass = false
        mv.showsScale = false
        mv.showsUserLocation = false
        mv.mapType = .mutedStandard
        mv.pointOfInterestFilter = .excludingAll
        mv.layer.cornerRadius = 20
        mv.clipsToBounds = true
        return mv
    }()

    private let mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        return view
    }()

    private lazy var recenterButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "location.fill")
        configuration.baseForegroundColor = .systemBlue
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.accessibilityLabel = "정류장 위치로 이동"
        button.addTarget(self, action: #selector(didTapRecenter), for: .touchUpInside)
        return button
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

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapRecenter() {
        mapView.setRegion(stationRegion, animated: true)
    }

    private var stationRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(
            latitude: busStation.latitude,
            longitude: busStation.longitude
        )
        return MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 350,
            longitudinalMeters: 350
        )
    }

    private let naviTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = .label
        lbl.font = .systemFont(ofSize: 17, weight: .semibold)
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.8
        return lbl
    }()

    private let refreshControl = UIRefreshControl()

    private let loadIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAutoRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }

    var isGoToWork: Bool
    init(busStation: BusStationEntity, isGoToWork: Bool) {
        self.isGoToWork = isGoToWork
        self.busStation = busStation
        self.vm = BusStationDIContainer().makeViewModel(isGoToWork: isGoToWork)
        naviTitleLbl.text = busStation.name + " 버스역"


        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension BusStationViewController {
    private func setUp() {
        configure()
        setTableView()
        setNavi()
        addViews()
        setConstraints()
        bind()
        fetch()

    }

    private func setTableView(){
        tableView = UITableView()
        //        tableView = UITableView(frame: .zero, style: .plain)
//        tableView.dataSource = self
//        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 60
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0

        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BusStationTableViewCell.self, forCellReuseIdentifier: BusStationTableViewCell.cellId)
        tableView.refreshControl = refreshControl
        refreshControl.transform = .init(scaleX: 0.75, y: 0.75)
        //        tableView.register(CommunityHeaderView.self, forHeaderFooterViewReuseIdentifier: CommunityHeaderView.headerViewID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func configure() {
        view.backgroundColor = .systemBackground
        mapView.delegate = self
        configureMap()
        configureLocation()
    }

    private func fetch() {
        vm.fetchFirstPage(nodeId: busStation.id)
    }

    private func bind() {
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        vm.output.isRefetchLoading
            .distinctUntilChanged()
            .drive() { [weak self] isLoading in
                guard let self else { return }
                isLoading ? self.refreshControl.beginRefreshing() : self.refreshControl.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        vm.output.isLoading
            .distinctUntilChanged()
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                isLoading ? self.loadIndicator.startAnimating() : self.loadIndicator.stopAnimating()
            })
            .disposed(by: self.disposeBag)

        vm.output.busStationList
            .drive(tableView.rx.items(cellIdentifier: BusStationTableViewCell.cellId)) { indexPath, item, cell in
                if let cell = cell as? BusStationTableViewCell {
                    cell.selectionStyle = .none
                    cell.configure(busNumber: item.bus.routeNo,
                                   busType: item.bus.routeType,
                                   busTime: item.arrival?.remainSeconds,
                                   busStationAgo: item.arrival?.remainStationCount)

                    cell.setFavorite(item.isFavorite)

                    cell.starBtn.rx.tap
                        .subscribe(onNext: { [weak self] in
                            guard let self else { return }

                            self.vm.toggleFavorite(
                                bus: item.bus,
                                station: self.busStation
                            )
                        })
                        .disposed(by: cell.disposeBag)
                }
            }
            .disposed(by: self.disposeBag)
    }

    @objc private func handleRefresh() {
        vm.refetch(nodeId: busStation.id)
    }

    private func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshDisposable = Observable<Int>
            .interval(.seconds(60), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.vm.refetch(nodeId: self.busStation.id, showsRefreshControl: false)
            })
    }

    private func stopAutoRefresh() {
        autoRefreshDisposable?.dispose()
        autoRefreshDisposable = nil
    }

    private func setNavi() {
        navigationController?.navigationBar.isHidden = true
    }

    private func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(naviTitleLbl)

        view.addSubview(mapContainerView)
        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(recenterButton)

        view.addSubview(tableView)
        tableView.addSubview(loadIndicator)
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

        naviTitleLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-60)

        }

        mapContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }

        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        recenterButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }


        tableView.snp.makeConstraints { make in
            make.top.equalTo(mapContainerView.snp.bottom).offset(12)
            make.bottom.leading.trailing.equalToSuperview()

        }
        loadIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}

extension BusStationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        default:
            mapView.showsUserLocation = false
        }
    }

    private func configureMap() {
        let coordinate = stationRegion.center
        mapView.setRegion(stationRegion, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = busStation.name + " 버스역"
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: false)
    }

    private func configureLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

}


extension BusStationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 내 위치(파란 점)는 기본 스타일 그대로 쓰기
        if annotation is MKUserLocation { return nil }

        let identifier = "BusAnnotation"

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true
            view?.displayPriority = .required

            let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
            view?.glyphImage = UIImage(systemName: "bus.fill", withConfiguration: config)
            view?.glyphTintColor = .white
            view?.markerTintColor = .systemBlue
        } else {
            view?.annotation = annotation
        }
        return view
    }
}
