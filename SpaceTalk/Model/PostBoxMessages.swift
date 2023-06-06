//
//  PostBoxMessages.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/29.
//

import Foundation

struct PostBoxMessages: Identifiable, Codable{
    var id: String {messageId}
    var senderNickName: String
    var messageText: String
    var messageId: String
    var senderId: String
    var receiverId: String
    var isFirstMessage: Bool
    var isRead: Bool
    var roomId: String
    var sendTime: Date

}

