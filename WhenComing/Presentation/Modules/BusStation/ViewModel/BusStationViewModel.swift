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
    private let errorRelay = PublishRelay<Error>()
    private var cityCode: String
    
    struct StationBusRow {
        let bus: StationThrghBusEntity
        let arrival: BusStationArrivalInfoEntity?
    }
    
    // MARK: - Input/Output
    struct Input {
        
    }
    struct Output {
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
            Observable.combineLatest(busListRelay, arrivalDictRelay)
                .map { buses, dict in
                    buses.map { bus in
                        StationBusRow(
                            bus: bus,
                            arrival: dict[bus.routeId]
                        )
                    }
                }
                .asDriver(onErrorJustReturn: [])
        
        
        // MARK: - transform
        
        self.output = Output(
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            busStationList: rows.asDriver()
        )
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
        busListRelay.accept([])
        getStationThrghBusList(nodeId: nodeId)
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
    
    
    func getStationArrivalInfo(nodeId: String) {
        Task { [weak self] in
            guard let self else { return }
            
            defer {}
            do {
                let items = try await getBusArrivalInfoUseCase.execute(cityCode: self.cityCode, nodeId: nodeId)
                var arrivalDict: [String: BusStationArrivalInfoEntity] = [:]
                for item in items {
                    arrivalDict[item.routeId] = item
                }
                self.arrivalDictRelay.accept(arrivalDict)
                print("getStationArrivalInfo item:\(items)")
            } catch {
                self.arrivalDictRelay.accept([:])
                print("getStationArrivalInfo error: \(error)")
            }
        }
    }
    
}
