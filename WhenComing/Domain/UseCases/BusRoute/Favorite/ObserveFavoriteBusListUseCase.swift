//
//  ObserveFavoriteBusListUseCase.swift
//  WhenComing
//
//  Created by jh on 5/25/26.
//

import Foundation
import RxSwift

protocol ObserveFavoriteBusListUseCase {
    func execute() -> Observable<[FavoriteBusEntity]>
    func reload()
}

final class DefaultObserveFavoriteBusListUseCase: ObserveFavoriteBusListUseCase {
    private let repo: FavoriteBusRepositoryProtocol

    init(repo: FavoriteBusRepositoryProtocol) {
        self.repo = repo
    }

    func execute() -> Observable<[FavoriteBusEntity]> {
        repo.observeFavorites()
    }

    func reload() {
        repo.reload()
    }
}
