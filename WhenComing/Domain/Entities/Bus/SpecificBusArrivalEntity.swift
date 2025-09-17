//
//  SpecificBusArrivalEntity.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

struct SpecificBusArrivalEntity {
    let nodeId: String // 정류소 Id
    let nodeName: String // 정류소 이름
    
    let routeId: String // 버스 노선 Id
    let routeNo: String // 버스 번호
    
    let arrivalTime: Int // 남은 시간 초단위
    let arrivalAtStationCount: Int // 몇번째전인지
}

