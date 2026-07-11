//
//  BusRouteViewController.swift
//  WhenComing
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

private final class BusRouteStationCell: UITableViewCell {
    static let cellId = "BusRouteStationCell"

    private let orderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 1
        return label
    }()

    private let nearbyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(orderLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nearbyLabel)

        orderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(36)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(orderLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(nearbyLabel.snp.leading).offset(-12)
        }

        nearbyLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(station: BusRouteInfoEntity, isNearby: Bool) {
        orderLabel.text = String(station.nodeOrd)
        nameLabel.text = station.nodeNm
        nearbyLabel.text = isNearby ? "근처" : nil
    }
}

final class BusRouteViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    private let route: BusRouteEntity
    private let isGoToWork: Bool
    private let viewModel: BusRouteViewModel

    private var allStations: [BusRouteInfoEntity] = []
    private var currentLocation: CLLocation?
    private var isRouteLoading = false
    private var hasStartedLoading = false

    private var displayedStations: [BusRouteInfoEntity] {
        allStations.filter { $0.upDownCd == directionSegmentControl.selectedIndex }
    }

    private var nearestStation: BusRouteInfoEntity? {
        guard let currentLocation else { return nil }
        return displayedStations
            .filter { station in
                (-90...90).contains(station.lat) &&
                (-180...180).contains(station.lng) &&
                station.lat != 0 &&
                station.lng != 0
            }
            .min { lhs, rhs in
                let lhsLocation = CLLocation(latitude: lhs.lat, longitude: lhs.lng)
                let rhsLocation = CLLocation(latitude: rhs.lat, longitude: rhs.lng)
                return lhsLocation.distance(from: currentLocation)
                    < rhsLocation.distance(from: currentLocation)
            }
    }

    private let headerView = UIView()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.baseForegroundColor = .label
        button.configuration = configuration
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let routeSummaryView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 14
        return view
    }()

    private let routeTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()

    private let routeDirectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 2
        return label
    }()

    private let directionSegmentControl = SegmentControlView(titles: ["상행", "하행"])

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 56
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 20)
        tableView.register(BusRouteStationCell.self, forCellReuseIdentifier: BusRouteStationCell.cellId)
        return tableView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    init(
        route: BusRouteEntity,
        isGoToWork: Bool,
        viewModel: BusRouteViewModel
    ) {
        self.route = route
        self.isGoToWork = isGoToWork
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        titleLabel.text = "\(route.routeNo)번 노선"
        routeTypeLabel.text = route.routeType
        routeDirectionLabel.text = "\(route.startNodeName)  →  \(route.endNodeName)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func directionChanged(_ sender: SegmentControlView) {
        updateDisplayedStations(scrollToNearest: true)
    }
}

private extension BusRouteViewController {
    func setUp() {
        configure()
        addViews()
        setConstraints()
        bind()
        configureLocation()
        viewModel.fetchAllStations()
    }

    func configure() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
    }

    func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        view.addSubview(routeSummaryView)
        routeSummaryView.addSubview(routeTypeLabel)
        routeSummaryView.addSubview(routeDirectionLabel)
        view.addSubview(directionSegmentControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)
    }

    func setConstraints() {
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

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(60)
        }

        routeSummaryView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(76)
        }

        routeTypeLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(14)
        }

        routeDirectionLabel.snp.makeConstraints { make in
            make.top.equalTo(routeTypeLabel.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        directionSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(routeSummaryView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(directionSegmentControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalTo(tableView).inset(24)
        }
    }

    func bind() {
        directionSegmentControl.addTarget(
            self,
            action: #selector(directionChanged(_:)),
            for: .valueChanged
        )

        viewModel.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                self.isRouteLoading = isLoading
                if isLoading { self.hasStartedLoading = true }
                isLoading
                    ? self.loadingIndicator.startAnimating()
                    : self.loadingIndicator.stopAnimating()
                self.updateEmptyState()
            })
            .disposed(by: disposeBag)

        viewModel.output.stations
            .drive(onNext: { [weak self] stations in
                guard let self else { return }
                self.allStations = stations
                self.updateDisplayedStations(scrollToNearest: self.currentLocation != nil)
            })
            .disposed(by: disposeBag)

        viewModel.output.error
            .emit(onNext: { error in
                print("BusRouteViewModel error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    func configureLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func updateDisplayedStations(scrollToNearest: Bool) {
        tableView.reloadData()
        updateEmptyState()

        guard scrollToNearest else { return }
        DispatchQueue.main.async { [weak self] in
            self?.scrollToNearestStation()
        }
    }

    func updateEmptyState() {
        let direction = directionSegmentControl.selectedIndex == 0 ? "상행" : "하행"
        emptyLabel.text = "\(direction) 정류장 정보가 없습니다"
        emptyLabel.isHidden = !hasStartedLoading || isRouteLoading || !displayedStations.isEmpty
    }

    func scrollToNearestStation() {
        guard let nearestStation,
              let row = displayedStations.firstIndex(where: {
                  stationKey($0) == stationKey(nearestStation)
              }) else { return }

        tableView.scrollToRow(
            at: IndexPath(row: row, section: 0),
            at: .top,
            animated: true
        )
    }

    func stationKey(_ station: BusRouteInfoEntity) -> String {
        "\(station.upDownCd)|\(station.nodeId)|\(station.nodeOrd)"
    }

    func openBusStation(_ station: BusRouteInfoEntity) {
        let busStation = BusStationEntity(
            id: station.nodeId,
            name: station.nodeNm,
            latitude: station.lat,
            longitude: station.lng,
            stationNumber: station.nodeNo > 0 ? String(station.nodeNo) : nil
        )
        let viewController = BusStationViewController(
            busStation: busStation,
            isGoToWork: isGoToWork
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension BusRouteViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        displayedStations.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedStations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let station = displayedStations[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BusRouteStationCell.cellId,
            for: indexPath
        ) as! BusRouteStationCell
        cell.configure(
            station: station,
            isNearby: nearestStation.map { stationKey($0) == stationKey(station) } ?? false
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openBusStation(displayedStations[indexPath.row])
    }
}

extension BusRouteViewController: CLLocationManagerDelegate {
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
        currentLocation = location
        manager.stopUpdatingLocation()
        updateDisplayedStations(scrollToNearest: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
