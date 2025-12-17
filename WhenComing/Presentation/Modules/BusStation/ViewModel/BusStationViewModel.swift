//
//  BusStationViewModel.swift
//  WhenComing
//
//  Created by jh on 12/1/25.
//


import Foundation
import RxSwift
import RxCocoa

final class BusStationViewModel {
    
    private let disposeBag = DisposeBag()
    private let busListRelay = BehaviorRelay<[StationThrghBusEntity]>(value: [])
    private let arrivalDictRelay = BehaviorRelay<[String: BusStationArrivalInfoEntity]>(value: [:])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let isRefetchLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private var cityCode: String
    // 0이면 멈춤, 1부터 카운트 시작
    private let remainingTimeRelay = BehaviorRelay<Int>(value: 0)
    private var remainingTimeTimer: Disposable?
    
    struct StationBusRow {
        let bus: StationThrghBusEntity
        let arrival: BusStationArrivalInfoEntity?
    }
    
    // MARK: - Input/Output
    struct Input {
        
    }
    struct Output {
        let isRefetchLoading: Driver<Bool>
        let isLoading: Driver<Bool>
        let error: Signal<Error>
        let busStationList: Driver<[StationBusRow]>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    private let getNearbyStationListUseCase: GetNearbyStationListUseCase
    private let getStationThrghBusListUseCase: GetStationThrghBusListUseCase
    private let getBusArrivalInfoUseCase: GetBusArrivalInfoUseCase
    
    
    
    // MARK: - Init
    init(
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase,
        getNearbyStationListUseCase: GetNearbyStationListUseCase,
        getStationThrghBusListUseCase: GetStationThrghBusListUseCase,
        getBusArrivalInfoUseCase: GetBusArrivalInfoUseCase
    ) {
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        self.getNearbyStationListUseCase = getNearbyStationListUseCase
        self.getStationThrghBusListUseCase = getStationThrghBusListUseCase
        self.getBusArrivalInfoUseCase = getBusArrivalInfoUseCase
        
        
        self.cityCode = String(loadSaveCityCodeUseCase.load() ?? 0)
        print("BusStationViewModel cityCode:\(cityCode)")
        
        self.input = Input()
        
        let rows: Driver<[StationBusRow]> =
            Observable.combineLatest(busListRelay, arrivalDictRelay, remainingTimeRelay)
                .map { buses, dict, remainingTime in
                    // remainingTime: 0이면 멈춤, 1부터 카운트 시작 → elapsed는 (remainingTime)
                    let elapsed = max(0, remainingTime)

                    return buses.map { bus in
                        if let arrival = dict[bus.routeId] {
                            var adjustedArrival = arrival
                            let base = adjustedArrival.remainSeconds
                            adjustedArrival.remainSeconds = max(0, base - elapsed)
                            return StationBusRow(bus: bus, arrival: adjustedArrival)
                        } else {
                            return StationBusRow(bus: bus, arrival: nil)
                        }
                    }
                }
                .asDriver(onErrorJustReturn: [])
        
        
        // MARK: - transform
        
        self.output = Output(
            isRefetchLoading: isRefetchLoadingRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            busStationList: rows.asDriver()
        )
    }
    
    private func startRemainingTimeTimerIfNeeded() {
        // 이미 돌고 있으면 중복 생성 방지
        if remainingTimeTimer != nil { return }

        remainingTimeTimer = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(remainingTimeRelay)
            .filter { $0 > 0 }      // 0이면 멈춘 상태
            .map { $0 + 1 }         // 1초마다 +1
            .subscribe(onNext: { [weak self] newValue in
                self?.remainingTimeRelay.accept(newValue)
            })

        remainingTimeTimer?
            .disposed(by: disposeBag)
    }
    
    
    private func bind() {
       
    }
    
    /*
     주변의 정류장 보여주는건 일단 보류
    func fetchNearbyStationList(lat: Double, lng: Double) async throws {
        let _ = try await getNearbyStationListUseCase.execute(pageNo: 1, lat: lat, lng: lng)
    }
    */
    
    
    func fetchFirstPage(nodeId: String) {
        isLoadingRelay.accept(true)
        getStationThrghBusList(nodeId: nodeId)
        getStationArrivalInfo(nodeId: nodeId)
    }
    
    func refetch(nodeId: String) {
        // 카운트/타이머 리셋
        remainingTimeRelay.accept(0)
        remainingTimeTimer?.dispose()
        remainingTimeTimer = nil
        isRefetchLoadingRelay.accept(true)
        
        getStationArrivalInfo(nodeId: nodeId)
    }
    
    private func getStationThrghBusList(nodeId: String) {
        Task { [weak self] in
            guard let self else { return }
            
            defer {
                self.isLoadingRelay.accept(false)
            }
            do {
                let items = try await getStationThrghBusListUseCase.execute(cityCode: self.cityCode, nodeId: nodeId)
                print("getStationThrghBusList item:\(items)")
                self.busListRelay.accept(items)
                
            } catch {
                print("getStationThrghBusList error: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getStationArrivalInfo(nodeId: String) {
        Task { [weak self] in
            guard let self else { return }
            
            defer {
                self.isRefetchLoadingRelay.accept(false)
            }
            do {
                let items = try await getBusArrivalInfoUseCase.execute(cityCode: self.cityCode, nodeId: nodeId)
                var arrivalDict: [String: BusStationArrivalInfoEntity] = [:]
                for item in items {
                    arrivalDict[item.routeId] = item
                }
                self.arrivalDictRelay.accept(arrivalDict)

                // 결과를 보낼 때 remainingTime을 1로 시작하고, 1초마다 증가
                self.remainingTimeRelay.accept(1)
                self.startRemainingTimeTimerIfNeeded()

                print("getStationArrivalInfo item:\(items)")
            } catch {
                self.arrivalDictRelay.accept([:])

                // 데이터가 없으면 카운트도 멈춤
                self.remainingTimeRelay.accept(0)
                self.remainingTimeTimer?.dispose()
                self.remainingTimeTimer = nil

                print("getStationArrivalInfo error: \(error)")
            }
        }
    }
    
}
