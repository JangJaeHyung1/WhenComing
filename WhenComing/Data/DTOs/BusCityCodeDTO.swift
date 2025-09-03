//
//  CityCodeDTO.swift
//  WhenComing
//
//  Created by jh on 5/10/25.
//

import Foundation

struct CityCodeListResponseDTO: Decodable {
    let response: CityCodeResponse
}

struct CityCodeResponse: Decodable {
    let header: CityCodeHeader
    let body: CityCodeBody
}

struct CityCodeHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct CityCodeBody: Decodable {
    let items: CityCodeItems
}

struct CityCodeItems: Decodable {
    let item: [CityCodeDTO]
}

struct CityCodeDTO: Decodable {
    let cityCode: Int
    let cityName: String

    private enum CodingKeys: String, CodingKey {
        case cityCode = "citycode"
        case cityName = "cityname"
    }
}

extension CityCodeDTO {
    func toEntity() -> CityCodeEntity {
        return CityCodeEntity(
            code: cityCode,
            name: cityName
        )
    }
}
