//
//  UserProfile.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Foundation

// ini adalah placeholder layer model
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var userName: String
    var email: String
}
