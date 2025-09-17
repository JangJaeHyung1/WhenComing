//
//  SpecificBusArrivalDTO.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//
import Foundation

struct SpecificBusArrivalDTO: Decodable {
    let arrPrevStationCnt: Int
    let arrTime: Int
    let nodeId: String
    let nodeNm: String
    let routeId: String
    let routeNo: String     // accepts Int or String from JSON
    let routeTp: String
    let vehicleTp: String

    private enum CodingKeys: String, CodingKey {
        case arrPrevStationCnt = "arrprevstationcnt"
        case arrTime = "arrtime"
        case nodeId = "nodeid"
        case nodeNm = "nodenm"
        case routeId = "routeid"
        case routeNo = "routeno"
        case routeTp = "routetp"
        case vehicleTp = "vehicletp"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        arrPrevStationCnt = try c.decodeIfPresent(Int.self, forKey: .arrPrevStationCnt) ?? 0
        arrTime = try c.decodeIfPresent(Int.self, forKey: .arrTime) ?? 0
        nodeId = try c.decodeIfPresent(String.self, forKey: .nodeId) ?? ""
        nodeNm = try c.decodeIfPresent(String.self, forKey: .nodeNm) ?? ""
        routeId = try c.decodeIfPresent(String.self, forKey: .routeId) ?? ""
        if let n = try? c.decode(Int.self, forKey: .routeNo) { routeNo = String(n) } else { routeNo = try c.decodeIfPresent(String.self, forKey: .routeNo) ?? "" }
        routeTp = try c.decodeIfPresent(String.self, forKey: .routeTp) ?? ""
        vehicleTp = try c.decodeIfPresent(String.self, forKey: .vehicleTp) ?? ""
    }
}

struct SpecificBusArrivalResponseDTO: Decodable {
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
        let item: [SpecificBusArrivalDTO]

        private enum CodingKeys: String, CodingKey { case item }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            if let arr = try? c.decode([SpecificBusArrivalDTO].self, forKey: .item) {
                self.item = arr
            } else if let single = try? c.decode(SpecificBusArrivalDTO.self, forKey: .item) {
                self.item = [single]
            } else {
                self.item = []
            }
        }
    }
}

extension SpecificBusArrivalDTO {
    func toEntity() -> SpecificBusArrivalEntity {
        return SpecificBusArrivalEntity(nodeId: nodeId,
                                        nodeName: nodeNm,
                                        routeId: routeId,
                                        routeNo: routeNo,
                                        arrivalTime: arrTime,
                                        arrivalAtStationCount: arrPrevStationCnt)
    }
}
