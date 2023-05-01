//
//  Message.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import Foundation

struct Messages: Identifiable, Codable{
    var id: String
    var msgText: String
    var isMsgReceived: Bool
    var timeStamp: Date
    
    var formattedTime: String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko")
            dateFormatter.dateFormat = "a h시 mm분"
            return dateFormatter.string(from: timeStamp)
        }
    
}
