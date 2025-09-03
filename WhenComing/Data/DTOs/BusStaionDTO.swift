//
//  StaionDTO.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

struct StationListResponseDTO: Decodable {
    let response: StationResponse
}

struct StationResponse: Decodable {
    let header: StationHeader
    let body: StationBody
}

struct StationHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct StationBody: Decodable {
    let items: StationItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct StationItems: Decodable {
    let item: [BusStationDTO]
}

struct BusStationDTO: Decodable {
    let gpslati: Double
    let gpslong: Double
    let nodeid: String
    let nodenm: String
    let nodeno: String?

    enum CodingKeys: String, CodingKey {
        case gpslati
        case gpslong
        case nodeid
        case nodenm
        case nodeno
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            gpslati = try container.decode(Double.self, forKey: .gpslati)
            gpslong = try container.decode(Double.self, forKey: .gpslong)
            nodeid = try container.decode(String.self, forKey: .nodeid)
            nodenm = try container.decode(String.self, forKey: .nodenm)

            // nodeno가 Int 또는 String 또는 nil 값으로 들어옴
            if let nodenoString = try? container.decode(String.self, forKey: .nodeno) {
                nodeno = nodenoString
            } else if let nodenoInt = try? container.decode(Int.self, forKey: .nodeno) {
                nodeno = String(nodenoInt)
            } else {
                nodeno = nil
            }
        }
}

extension BusStationDTO {
    func toEntity() -> BusStationEntity {
        return BusStationEntity(
            id: nodeid,
            name: nodenm,
            latitude: gpslati,
            longitude: gpslong,
            stationNumber: nodeno
        )
    }
}
