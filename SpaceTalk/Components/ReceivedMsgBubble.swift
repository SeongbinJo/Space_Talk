//
//  ReceivedMsgBubble.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import SwiftUI

struct ReceivedMsgBubble: View {
    
    var message: Message
    
    var body: some View {
        Text(message.formattedTime)
            .foregroundColor(.gray)
            .font(.system(size: 15))
        HStack{
            Text(message.msgText)
                .font(.system(size: 20))
                .padding(10)
                .background(message.isMsgReceived ? .gray : .yellow)
                .cornerRadius(15, corners: .allCorners)
        }
    }
}

struct ReceivedMsgBubble_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedMsgBubble(message: Message(id: "123", msgText: "hi, this is my first message bubble. i feel so good!", isMsgReceived: false, timeStamp: Date()))
    }
}
