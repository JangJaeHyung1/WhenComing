//
//  BusArrivalDTO.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

struct BusArrivalListResponseDTO: Decodable {
    let response: BusArrivalListInnerResponse
}

struct BusArrivalListInnerResponse: Decodable {
    let header: BusArrivalHeader
    let body: BusArrivalBody
}

struct BusArrivalHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct BusArrivalBody: Decodable {
    let items: BusArrivalItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct BusArrivalItems: Decodable {
    let item: [BusArrivalDTO]
}

struct BusArrivalDTO: Decodable {
    let arrPrevStationCount: Int
    let arrTime: Int
    let nodeId: String
    let nodeName: String
    let routeId: String
    let routeNo: Int
    let routeType: String
    let vehicleType: String

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
}
