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
//    var receiverId: String // 메시지 받는 사람 id
    var isRead: Bool // 메시지 읽었는지.
//    var senderNickname: String // 메시지 발신자 닉네임
    
    
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
    
    init?(dictionaryData: [String: Any]){
        guard let messageId = dictionaryData["messageId"] as? String,
              let roomId = dictionaryData["roomId"] as? String,
              let messageText = dictionaryData["messageText"] as? String,
              let sendTime = dictionaryData["sendTime"] as? Timestamp,
              let senderId = dictionaryData["senderId"] as? String,
//              let receiverId = dictionaryData["receiverId"] as? String,
              let isRead = dictionaryData["isRead"] as? Bool else {
//              let senderNickname = dictionaryData["senderNickname"] as? String else{
            print("Messages 모델 에러 : \(dictionaryData)")
            return nil
        }
        
        self.messageId = messageId
        self.roomId = roomId
        self.messageText = messageText
        self.sendTime = sendTime.dateValue()
        self.senderId = senderId
//        self.receiverId = receiverId
        self.isRead = isRead
//        self.senderNickname = senderNickname
        
    }
    
}
