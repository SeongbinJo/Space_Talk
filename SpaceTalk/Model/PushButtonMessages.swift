//
//  PostBoxMessages.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/29.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct PushButtonMessages: Identifiable, Codable{
    var id: String {messageId}
    var messageId: String // 메시지 id
    var roomId: String // 채팅방 id
    var messageText: String // 메시지 내용
    var sendTime: Date // 메시지 보낸 시간
    var recentSenderId: String // 메시지 보낸 사람 id
    var isRead: Bool // 메시지 읽었는지.
    var firstSenderId: String // 처음 메시지 보낸사람 id
    var firstReceiverId: String // 처음 메시지 받는사람 id
    var isAvailable: Bool // 상대방이 'O' 버튼 눌렀는지 여부
    var isExit: Bool //상대방이 나갔는지 여부
    var firstSenderNickname: String //처음 메시지 보낸 사람의 닉네임
    var firstReceiverNickname: String //처음 메시지 받은 사람의 닉네임

    
    
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

    init?(dictionaryData: [String: Any]) {
        guard let messageId = dictionaryData["messageId"] as? String,
            let roomId = dictionaryData["roomId"] as? String,
            let messageText = dictionaryData["messageText"] as? String,
            let sendTime = dictionaryData["sendTime"] as? Timestamp, //firestore에서 sendtime의 타입이 timestamp로 되어있기 때문.
            let recentSenderId = dictionaryData["recentSenderId"] as? String,
            let isRead = dictionaryData["isRead"] as? Bool,
            let firstSenderId = dictionaryData["firstSenderId"] as? String,
            let firstReceiverId = dictionaryData["firstReceiverId"] as? String,
            let isAvailable = dictionaryData["isAvailable"] as? Bool,
            let isExit = dictionaryData["isExit"] as? Bool,
            let firstReceiverNickname = dictionaryData["firstReceiverNickname"] as? String,
            let firstSenderNickname = dictionaryData["firstSenderNickname"] as? String else {
            print("PushButtonMessages 모델 에러 : \(dictionaryData)")
                return nil
        }
        
        self.messageId = messageId
        self.roomId = roomId
        self.messageText = messageText
        self.recentSenderId = recentSenderId
        self.isRead = isRead
        self.firstSenderId = firstSenderId
        self.firstReceiverId = firstReceiverId
        self.isAvailable = isAvailable
        self.isExit = isExit
        self.firstSenderNickname = firstSenderNickname
        self.firstReceiverNickname = firstReceiverNickname
        self.sendTime = sendTime.dateValue() //초기화 할 때, dateValue()를 사용하여 timestamp -> date로 형 변환.
    }
    
}
