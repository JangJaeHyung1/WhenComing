//
//  BusStationArrivalInfoEntity.swift
//  WhenComing
//
//  Created by jh on 12/7/25.
//

// BusStationArrivalInfoEntity.swift

import Foundation

struct BusStationArrivalInfoEntity {
    /// 노선 ID (예: "BSB5200039000") 버스 ID랑 다름
    let routeId: String

    /// 노선 번호 (예: "5-1", "39")
    let routeNo: String

    /// 노선 타입 (예: "일반버스")
    let routeType: String

    /// 차량 타입 (예: "일반차량", "저상버스")
    let vehicleType: String

    /// 정류장 ID
    let stationId: String

    /// 정류장 이름
    let stationName: String

    /// 남은 정류장 수
    let remainStationCount: Int

    /// 도착까지 남은 시간(초)
    var remainSeconds: Int
}
