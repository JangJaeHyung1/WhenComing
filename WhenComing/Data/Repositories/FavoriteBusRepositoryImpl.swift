//
//  FavoriteBusRepositoryImpl.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import Foundation
import RxSwift
import RxCocoa


final class FavoriteBusRepositoryImpl: FavoriteBusRepositoryProtocol {
  private let localDataSource: FavoriteBusLocalDataSource
  private let queue = DispatchQueue(label: "favorite.bus.repo.queue")

  private let relay: BehaviorRelay<[FavoriteBusEnitity]>
  private var cache: [FavoriteBusEnitity]

  init(localDataSource: FavoriteBusLocalDataSource) {
    self.localDataSource = localDataSource
    let initial = localDataSource.load()
    self.cache = initial
    self.relay = BehaviorRelay(value: initial)
  }

  func observeFavorites() -> Observable<[FavoriteBusEnitity]> {
    relay.asObservable()
  }

  func isFavorite(id: String) -> Bool {
    queue.sync {
      cache.contains(where: { $0.id == id })
    }
  }

  func toggle(_ item: FavoriteBusEnitity) {
    queue.async { [weak self] in
      guard let self else { return }

      var next = self.cache
      if let idx = next.firstIndex(where: { $0.id == item.id }) {
        next.remove(at: idx)
      } else {
        next.insert(item, at: 0)
      }

      self.cache = next
      self.localDataSource.save(next)

      DispatchQueue.main.async {
        self.relay.accept(next)
      }
    }
  }
}
