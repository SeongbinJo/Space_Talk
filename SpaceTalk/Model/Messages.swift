//
//  Message.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import Foundation
import Firebase

struct Messages: Identifiable, Codable{
    var id: String { messageId }
    var messageId: String // 메시지 id
    var roomId: String // 채팅방 id
    var messageText: String // 메시지 내용
    var sendTime: Date // 메시지 보낸 시간
    var senderId: String // 메시지 보낸 사람 id
    var receiverId: String // 메시지 받는 사람 id
    var isRead: Bool // 메시지 읽었는지.
    
    
    var formattedTime: String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko")
            dateFormatter.dateFormat = "a h시 mm분"
            return dateFormatter.string(from: sendTime)
        }
}
