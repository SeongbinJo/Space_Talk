//
//  MessageBubble.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import SwiftUI

struct MessageBubble: View {
    
    var message: Message
    
    var body: some View {
            VStack(alignment: message.isMsgReceived ? .leading : .trailing){
                HStack(alignment: .bottom){
                    //수신과 발신의 차이에 따라 시간표시를 달리하기 위해서 메시지 Hstack 앞뒤로 숨긴 시간과 숨기지 않은 시간 두 개를 추가함.
                    Text(message.formattedTime)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .frame(width: message.isMsgReceived ? 0 : 80, height: message.isMsgReceived ? 0 : 25)
                        .padding(.horizontal, -5)
                    HStack{
                        Text(message.msgText)
                            .font(.system(size: 17))
                            .padding(10)
                            .background(message.isMsgReceived ? .pink : .yellow)
                            .cornerRadius(12, corners: .allCorners)
                    }
                    Text(message.formattedTime)
                        .foregroundColor(.black)
                        .font(.system(size: 15))
                        .frame(width: message.isMsgReceived ? 80 : 0, height: message.isMsgReceived ? 25 : 0)
                        .padding(.horizontal, -5)
                }
                .frame(maxWidth: 400, alignment: message.isMsgReceived ? .leading : .trailing)
            }
            .frame(maxWidth: .infinity, alignment: message.isMsgReceived ? .leading : .trailing)

    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: Message(id: "123", msgText: "hi, this is my first message bubble. i feel so good!", isMsgReceived: false, timeStamp: Date()))
    }
}
