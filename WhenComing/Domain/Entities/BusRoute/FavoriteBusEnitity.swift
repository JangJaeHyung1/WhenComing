//
//  FavoriteBusEnitity.swift
//  WhenComing
//
//  Created by jh on 9/15/25.
//

import Foundation

struct FavoriteBusEnitity: Codable {
    var id: String { "\(cityCode)|\(stationId)|\(routeId)" }
    
    // api 호출용
    var cityCode: String
    var stationId: String // 정류소 ID
    var routeId: String // 버스 노선 ID
    
    // view 노출용
    let stationName: String // 정류소 이름
    let routeNo: String // 버스 번호
    let routeType: String // 버스 타입
    
    // 추후에 정렬용으로 쓸수도 있음
    let latitude: Double
    let longitude: Double
}
