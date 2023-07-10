//
//  MessageBubble.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import SwiftUI

struct MessageBubble: View {
    
    @ObservedObject var loginViewModel: LoginViewModel

    var message: Messages
    
    @State var geoHeight: CGFloat = 0

    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack(alignment: .bottom, spacing: 1){
                    Text(message.isRead ? "" : "1")
                        .foregroundColor(.yellow)
                        .font(.system(size: geometry.size.width * 0.03))
                        .frame(width: message.senderId == loginViewModel.currentUser!.uid ? geometry.size.width * 0.03 : 0)
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.03))
                    // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 width = 0으로 정함.
//                        .frame(width: geometry.size.width * 0.2)
                        .frame(width: message.senderId == loginViewModel.currentUser!.uid ? geometry.size.width * 0.2 : 0)
                    Text(message.messageText)
                        .font(.system(size: geometry.size.width * 0.04))
                        .padding(7)
                        .background{
                            message.senderId == loginViewModel.currentUser!.uid ? Color.yellow : Color.pink
                            GeometryReader{ geo in
                                Text("")
                                    .onAppear{
                                        geoHeight = geo.size.height
                                    }
                            }
                        }
                        .cornerRadius(5, corners: .allCorners)
                        .padding(message.senderId != loginViewModel.currentUser!.uid ? .leading : .trailing, 10)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.03))
                    // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 width = 0으로 정함.
//                        .frame(width: 0)
                        .frame(width: message.senderId != loginViewModel.currentUser!.uid ? geometry.size.width * 0.2 : 0)
                    Text(message.isRead ? "" : "1")
                        .foregroundColor(.yellow)
                        .font(.system(size: geometry.size.width * 0.03))
                        .frame(width: message.senderId != loginViewModel.currentUser!.uid ? geometry.size.width * 0.03 : 0)
                }
                // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
                .frame(maxWidth: geometry.size.width * 0.9, maxHeight: .infinity, alignment: message.senderId == loginViewModel.currentUser!.uid ? .trailing : .leading)
            }
            // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: message.senderId == loginViewModel.currentUser!.uid ? .trailing : .leading)
        }
        .frame(height: geoHeight)
    }
    
}

//struct MessageBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageBubble(loginViewModel: LoginViewModel(), message: Messages(messageId: "dd", roomId: "asdf", messageText: "hihi", sendTime: Date(), senderId: "123", receiverId: "321", isRead: false))
//    }
//}
