//
//  Users.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/30.
//

import Foundation

struct Users: Codable{
    var uid: String
    var nickName: String
    var email: Bool
    var registerDate: Date
}
