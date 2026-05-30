//
//  FavoriteBusLocalDataSource.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import Foundation

protocol FavoriteBusLocalDataSource {
  func load() -> [FavoriteBusEntity]
  func save(_ list: [FavoriteBusEntity])
}

final class DefaultFavoriteBusLocalDataSource: FavoriteBusLocalDataSource {
  private let userDefaults: UserDefaults
  private let storageKey: String
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  init(userDefaults: UserDefaults = .standard, storageKey: String = "favorite_bus_list") {
    self.userDefaults = userDefaults
    self.storageKey = storageKey

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    self.encoder = encoder
    self.decoder = decoder
  }

  func load() -> [FavoriteBusEntity] {
    guard let data = userDefaults.data(forKey: storageKey) else { return [] }
    return (try? decoder.decode([FavoriteBusEntity].self, from: data)) ?? []
  }

  func save(_ list: [FavoriteBusEntity]) {
    guard let data = try? encoder.encode(list) else { return }
    userDefaults.set(data, forKey: storageKey)
  }
}
