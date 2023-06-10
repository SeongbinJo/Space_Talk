//
//  PostBoxMessages.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/29.
//

import Foundation

struct PushButtonMessages: Identifiable, Codable{
    var id: String { messageId }
    var messageId: String // 메시지 id
    var roomId: String // 채팅방 id
    var messageText: String // 메시지 내용
    var sendTime: Date // 메시지 보낸 시간
    var senderId: String // 메시지 보낸 사람 id
    var receiverId: String // 메시지 받는 사람 id
    var isRead: Bool // 메시지 읽었는지.
    var senderNickName: String // 메시지 발신자 닉네임
    var receiverNickName: String // 메시지 수신자 닉네임
    var firstSenderId: String // 처음 메시지 보낸사람 id
    var firstReceiverId: String // 처음 메시지 받는사람 id
    var isAvailable: Bool // 상대방이 'O' 버튼 눌렀는지 여부.

    
    
    var formattedTime: String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko")
            dateFormatter.dateFormat = "a h시 mm분"
            return dateFormatter.string(from: sendTime)
        }
    
    var formattedDay: String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko")
            dateFormatter.dateFormat = "yyyy년 M월 d일"
            return dateFormatter.string(from: sendTime)
        }

}

