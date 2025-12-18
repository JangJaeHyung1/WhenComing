//
//  FavoriteBusRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import RxSwift

protocol FavoriteBusRepositoryProtocol {
  func observeFavorites() -> Observable<[FavoriteBusEnitity]>
  func toggle(_ item: FavoriteBusEnitity)
  func isFavorite(id: String) -> Bool
}
