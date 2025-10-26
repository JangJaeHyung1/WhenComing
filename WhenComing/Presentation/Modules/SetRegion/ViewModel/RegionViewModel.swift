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
    private let cityCodesRelay = BehaviorRelay<[BusCityCodeEntity]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private let dummyData: [String] = ["서울","부산","대구","대전","울산","제주","마산","전북","서울","부산",
                             "대구","대전","울산","제주","마산","전북","서울","부산","대구","대전",
                             "울산","제주","마산","전북","서울","부산","대구","대전","울산","제주",
                                       "서울","부산","대구","대전","울산","제주","마산","전북","서울","부산",
                                       "서울","부산","대구","대전","울산","제주","마산","전북","서울","부산",
                                       "서울","부산","대구","대전","울산","제주","마산","전북","서울","부산",]
    // MARK: - Input/Output
    struct Input {
        let fetchCityCodesTrigger: PublishRelay<Void>
        let searchQuery: PublishRelay<String>
    }
    struct Output {
        let cityCodes: Driver<[BusCityCodeEntity]>
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let getCityCodeListUseCase: GetCityCodeListUseCase
    private let loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    
    // MARK: - Init
    init(
        getCityCodeListUseCase: GetCityCodeListUseCase,
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    ) {
        self.getCityCodeListUseCase = getCityCodeListUseCase
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        
        self.input = Input(
            fetchCityCodesTrigger: PublishRelay<Void>(),
            searchQuery: PublishRelay<String>()
        )
        
        // MARK: - transform
        
        let filteredCityCodes = Observable
            .combineLatest(cityCodesRelay, input.searchQuery.startWith(""))
            .map { cityCodes, query in
                guard !query.isEmpty else { return cityCodes }
                return cityCodes.filter { $0.name.contains(query) }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.output = Output(
            cityCodes: filteredCityCodes,
            isLoading: isLoadingRelay.asObservable().asDriver(onErrorDriveWith: .empty()),
            error: errorRelay.asSignal()
        )
        
        bind()
    }
    
    
    
    private func bind() {
        input.fetchCityCodesTrigger
//            .filter { return false }
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    do {
                        let cityList = try await self.getCityCodeListUseCase.execute()
                        await MainActor.run {
                            self.cityCodesRelay.accept(cityList)
                            self.isLoadingRelay.accept(false)
                        }
                    } catch {
                        await MainActor.run {
                            self.errorRelay.accept(error)
                            self.isLoadingRelay.accept(false)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.fetchCityCodesTrigger
            .filter { return false }
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.cityCodesRelay.accept(dummyData.enumerated().map { index, name in
                    BusCityCodeEntity(code: index, name: name)
                })
            })
            .disposed(by: disposeBag)
    }
    
    
    func loadCityCode() -> Int? {
        self.loadSaveCityCodeUseCase.load()
    }
    
    func saveCityCode(_ code: Int) {
        self.loadSaveCityCodeUseCase.save(code)
    }
}
