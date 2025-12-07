//
//  ArroundStationDTO.swift
//  WhenComing
//
//  Created by jh on 9/15/25.
//
import Foundation

struct ArroundStationDTO: Decodable {
    let cityCode: Int
    let gpsLat: Double
    let gpsLong: Double
    let nodeId: String
    let nodeNm: String
    let nodeNo: Int

    private enum CodingKeys: String, CodingKey {
        case cityCode = "citycode"
        case gpsLat   = "gpslati"
        case gpsLong  = "gpslong"
        case nodeId   = "nodeid"
        case nodeNm   = "nodenm"
        case nodeNo   = "nodeno"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // Int fields (accept Int or String)
        if let v = try? c.decode(Int.self, forKey: .cityCode) {
            cityCode = v
        } else if let s = try? c.decode(String.self, forKey: .cityCode), let v = Int(s) {
            cityCode = v
        } else {
            cityCode = 0
        }

        if let v = try? c.decode(Int.self, forKey: .nodeNo) {
            nodeNo = v
        } else if let s = try? c.decode(String.self, forKey: .nodeNo), let v = Int(s) {
            nodeNo = v
        } else {
            nodeNo = 0
        }

        // Double fields (accept Double or String)
        if let v = try? c.decode(Double.self, forKey: .gpsLat) {
            gpsLat = v
        } else if let s = try? c.decode(String.self, forKey: .gpsLat), let v = Double(s) {
            gpsLat = v
        } else {
            gpsLat = 0
        }

        if let v = try? c.decode(Double.self, forKey: .gpsLong) {
            gpsLong = v
        } else if let s = try? c.decode(String.self, forKey: .gpsLong), let v = Double(s) {
            gpsLong = v
        } else {
            gpsLong = 0
        }

        nodeId = (try? c.decode(String.self, forKey: .nodeId)) ?? ""
        nodeNm = (try? c.decode(String.self, forKey: .nodeNm)) ?? ""
    }
}

struct ArroundStationResponseDTO: Decodable {
    let response: ResponseDTO

    struct ResponseDTO: Decodable {
        let header: HeaderDTO
        let body: BodyDTO
    }

    struct HeaderDTO: Decodable {
        let resultCode: String
        let resultMsg: String
    }

    struct BodyDTO: Decodable {
        let items: ItemsDTO
        let numOfRows: Int
        let pageNo: Int
        let totalCount: Int
    }

    struct ItemsDTO: Decodable {
        let item: [ArroundStationDTO]

        private enum CodingKeys: String, CodingKey { case item }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            if let arr = try? c.decode([ArroundStationDTO].self, forKey: .item) {
                self.item = arr
            } else if let single = try? c.decode(ArroundStationDTO.self, forKey: .item) {
                self.item = [single]
            } else {
                self.item = []
            }
        }
    }
}

// MARK: - Mappers (DTO -> Entity)

extension ArroundStationDTO {
    func toEntity() -> AroundBusStationEntity {
        return AroundBusStationEntity(lat: gpsLat,
                               lng: gpsLong,
                               nodeId: nodeId,
                               nodeNm: nodeNm,
                               nodeNo: nodeNo
        )
    }
}
