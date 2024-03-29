//
//  Users.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/30.
//

import Foundation

struct Users: Identifiable, Codable{
    var uid: String
    var nickName: String
    var email: String
    var registerDate: Date
    var selectChatRoomId: String
    var userNumber: Int
    var id: String { uid }
}
