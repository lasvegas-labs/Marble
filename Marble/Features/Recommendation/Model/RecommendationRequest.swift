//
//  RecommendationRequest.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Foundation

struct RecommendationRequest: Encodable {
    let role: String
    let age: String
    let stylePersonal: String
    let gender: String
    let hobby: [String]
    let app: String
    let time: String

    enum CodingKeys: String, CodingKey {
        case role
        case age
        case stylePersonal = "style_personal"
        case gender
        case hobby
        case app
        case time
    }
}
