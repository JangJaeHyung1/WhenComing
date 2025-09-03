//
//  BusStationViewModel.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class BusStationViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input/Output
    struct Input {
        let fetchCityCodesTrigger: PublishRelay<Void>
        let searchStationTrigger: PublishRelay<(pageNo: Int, cityCode: String, stationName: String)>
    }
    struct Output {
        let cityCodes: BehaviorRelay<[CityCodeDTO]>
        let busStations: BehaviorRelay<[BusStationDTO]>
        let isLoading: BehaviorRelay<Bool>
        let error: PublishRelay<Error>
    }
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let fetchCityCodeUseCase: FetchCityCodeListUseCase
    private let fetchBusStationListUseCase: FetchBusStationListUseCase
    
    // MARK: - Init
    init(
        fetchCityCodeUseCase: FetchCityCodeListUseCase,
        fetchBusStationListUseCase: FetchBusStationListUseCase
    ) {
        self.fetchCityCodeUseCase = fetchCityCodeUseCase
        self.fetchBusStationListUseCase = fetchBusStationListUseCase
        
        self.input = Input(
            fetchCityCodesTrigger: PublishRelay<Void>(),
            searchStationTrigger: PublishRelay<(pageNo: Int, cityCode: String, stationName: String)>()
        )
        self.output = Output(
            cityCodes: BehaviorRelay(value: []),
            busStations: BehaviorRelay(value: []),
            isLoading: BehaviorRelay(value: false),
            error: PublishRelay<Error>()
        )
        
        bind()
    }
    
    private func bind() {
        input.fetchCityCodesTrigger
            .subscribe(onNext:{ [weak self] res in
                guard let self else { return }
                Task {
                    do {
                        let cityList = try await self.fetchCityCodeUseCase.execute()
                        print("cityList:\(cityList)")
                    } catch {
                        print(error)
                    }
                    
                }
            })
            .disposed(by: disposeBag)
        
        input.searchStationTrigger
            .subscribe(onNext:{ [weak self] res in
                guard let self else { return }
                Task {
                    do {
                        print("searchStationTrigger")
                        let stationList = try await self.fetchBusStationListUseCase.execute(pageNo: res.pageNo, cityCode: res.cityCode, stationName: res.stationName)
                        print("stationList:\(stationList)")
                    }
                    catch {
                        print(error)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
