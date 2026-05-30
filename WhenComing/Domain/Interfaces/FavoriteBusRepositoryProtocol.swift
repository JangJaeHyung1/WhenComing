//
//  FavoriteBusRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import RxSwift

protocol FavoriteBusRepositoryProtocol {
  func observeFavorites() -> Observable<[FavoriteBusEntity]>
  func reload()
  func toggle(_ item: FavoriteBusEntity)
  func isFavorite(id: String) -> Bool
}
