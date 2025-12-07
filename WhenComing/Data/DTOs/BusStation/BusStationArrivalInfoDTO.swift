//
//  BusStationArrivalInfoDTO.swift
//  WhenComing
//
//  Created by jh on 12/7/25.
//

// BusStationArrivalInfoDTO.swift

import Foundation

struct BusStationArrivalInfoListResponseDTO: Decodable {
    let response: BusStationArrivalInfoResponse
}

struct BusStationArrivalInfoResponse: Decodable {
    let header: BusStationArrivalInfoHeader
    let body: BusStationArrivalInfoBody
}

struct BusStationArrivalInfoHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct BusStationArrivalInfoBody: Decodable {
    let items: BusStationArrivalInfoItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct BusStationArrivalInfoItems: Decodable {
    let item: [BusStationArrivalInfoDTO]
}

struct BusStationArrivalInfoDTO: Decodable {
    let arrPrevStationCount: Int      // arrprevstationcnt
    let arrTime: Int                  // arrtime (초 단위 도착 예정 시간)
    let nodeId: String                // nodeid
    let nodeName: String              // nodenm
    let routeId: String               // routeid
    let routeNo: String               // routeno (문자/숫자 혼합 → String 처리)
    let routeType: String             // routetp
    let vehicleType: String           // vehicletp

    private enum CodingKeys: String, CodingKey {
        case arrPrevStationCount = "arrprevstationcnt"
        case arrTime = "arrtime"
        case nodeId = "nodeid"
        case nodeName = "nodenm"
        case routeId = "routeid"
        case routeNo = "routeno"
        case routeType = "routetp"
        case vehicleType = "vehicletp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        arrPrevStationCount = try container.decode(Int.self, forKey: .arrPrevStationCount)
        arrTime = try container.decode(Int.self, forKey: .arrTime)
        nodeId = try container.decode(String.self, forKey: .nodeId)
        nodeName = try container.decode(String.self, forKey: .nodeName)
        routeId = try container.decode(String.self, forKey: .routeId)
        routeType = try container.decode(String.self, forKey: .routeType)
        vehicleType = try container.decode(String.self, forKey: .vehicleType)

        // routeno: "5-1" 처럼 문자열일 수도 있고, 39 처럼 숫자일 수도 있어서 둘 다 처리
        if let stringValue = try? container.decode(String.self, forKey: .routeNo) {
            routeNo = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .routeNo) {
            routeNo = String(intValue)
        } else {
            routeNo = ""
        }
    }
}

extension BusStationArrivalInfoDTO {
    func toEntity() -> BusStationArrivalInfoEntity {
        return BusStationArrivalInfoEntity(
            routeId: routeId,
            routeNo: routeNo,
            routeType: routeType,
            vehicleType: vehicleType,
            stationId: nodeId,
            stationName: nodeName,
            remainStationCount: arrPrevStationCount,
            remainSeconds: arrTime
        )
    }
}
