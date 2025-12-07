//
//  BusRouteInfoEntity.swift
//  WhenComing
//
//  Created by jh on 9/15/25.
//

import Foundation

struct BusRouteInfoEntity {
    let lat: Double
    let lng: Double
    let nodeId: String // 정류소 번호
    let nodeNm: String // 정류소 이름
    let nodeNo: Int
    let nodeOrd: Int // 노선중에 해당 정류소의 순서
    let routeId: String // 노선 번호
    let upDownCd: Int // 상행 하행 0 or 1
}
