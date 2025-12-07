//
//  BusStaionViewController.swift
//  WhenComing
//
//  Created by jh on 11/22/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MapKit

class BusStaionViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    var busStation: BusStationEntity
    private let vm = BusStationDIContainer().makeViewModel()
    // 헤더 컨테이너
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        return v
    }()

    private let mapView: MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.isRotateEnabled = false
        mv.showsUserLocation = false
        return mv
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
    
    private let naviTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .label
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    init(busStation: BusStationEntity) {
        self.busStation = busStation
        naviTitleLbl.text = busStation.name + " 버스역"
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension BusStaionViewController {
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
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .red
        //    private let refreshControl = UIRefreshControl()
        //    tableView.refreshControl = refreshControl
        //    refreshControl.transform = .init(scaleX: 0.75, y: 0.75)
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
        vm.getStationArrivalInfo(stationId: busStation.id)
    }
    
    private func bind() {
        
        vm.output.items
            .drive(onNext: {
                print("items: \($0)")
            })
            .disposed(by: disposeBag)
    }
    
    private func setNavi() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(naviTitleLbl)
        
        view.addSubview(mapView)
        
        view.addSubview(tableView)
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

        mapView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(mapView.snp.width).multipliedBy(3.0/4.0)
            make.leading.trailing.equalToSuperview()
        }
        
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        
        }
    }
}

extension BusStaionViewController: CLLocationManagerDelegate {
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
        // BusStationEntity에 맞게 프로퍼티 이름 수정해줘야 함
        let coordinate = CLLocationCoordinate2D(latitude: busStation.latitude, longitude: busStation.longitude)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = busStation.name + " 버스역"
        mapView.addAnnotation(annotation)
    }
    
    private func configureLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
}


extension BusStaionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 내 위치(파란 점)는 기본 스타일 그대로 쓰기
        if annotation is MKUserLocation { return nil }

        let identifier = "BusAnnotation"

        // Marker 스타일 (위에 동그란 glyph + 말풍선) 쓰고 싶으면 MKMarkerAnnotationView
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true

            let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold, scale: .large)
            view?.glyphImage = UIImage(systemName: "bus.fill", withConfiguration: config)
            view?.glyphTintColor = .white
            view?.markerTintColor = .black
            view?.isSelected = true
        } else {
            view?.annotation = annotation
        }
        return view
    }
}
