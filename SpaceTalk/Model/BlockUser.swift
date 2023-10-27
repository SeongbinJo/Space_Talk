//
//  BlockUser.swift
//  SpaceTalk
//
//  Created by 조성빈 on 10/27/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct BlockUser: Identifiable, Codable{
    var id : String { blockUserUID }
    var blockUserNickName : String // 차단유저의 닉네임
    var blockUserUID : String
}
