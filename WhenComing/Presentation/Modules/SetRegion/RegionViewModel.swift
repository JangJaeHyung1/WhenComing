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
    }
    struct Output {
        let cityCodes: BehaviorRelay<[CityCodeDTO]>
        let isLoading: BehaviorRelay<Bool>
        let error: PublishRelay<Error>
    }
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let getCityCodeUseCase: GetCityCodeListUseCase
    
    // MARK: - Init
    init(
        getCityCodeUseCase: GetCityCodeListUseCase,
    ) {
        self.getCityCodeUseCase = getCityCodeUseCase
        
        self.input = Input(
            fetchCityCodesTrigger: PublishRelay<Void>()
        )
        self.output = Output(
            cityCodes: BehaviorRelay(value: []),
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
                        let cityList = try await self.getCityCodeUseCase.execute()
                        print("cityList:\(cityList)")
                    } catch {
                        print(error)
                    }
                    
                }
            })
            .disposed(by: disposeBag)
        
    }
}
