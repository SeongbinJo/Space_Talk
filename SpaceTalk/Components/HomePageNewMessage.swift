//
//  HomePageNewMessage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/28.
//

import SwiftUI

struct HomePageNewMessage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var newMessage: Messages
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
            VStack{
                HStack{
                    Text("\(newMessage.senderNickName)님의 무전 : \(newMessage.messageText)")
                        .padding(.horizontal, 10)
                    Spacer()
                    Button(action: {
                        //'O' 버튼 눌렀을때, 해당 메시지를 따로 저장후 해당 위치에 후에 쌓일 메시지들 저장.(해당 수신,발신자)
                        firestoreViewModel.acceptNewMessage(roomid: newMessage.roomId)
                    }){
                        Text("O")
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        firestoreViewModel.refuseNewMessage(roomid: newMessage.roomId, messageid: newMessage.messageId)
                    }){
                        Text("X")
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 10)
                }
                .frame(width: width, height: height)
                .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                .cornerRadius(15, corners: .allCorners)
//                        .position(x: geomtry.frame(in: .local).midX)
//                        .padding(10)
            }
        }
    }


//struct HomePageNewMessage_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePageNewMessage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), newMessage: PostBoxMessages(senderNickName: "조성빈", messageText: "안녕하세요!", messageId: "asdf", senderId: "123asdf", receiverId: "asdf123", isFirstMessage: true, isRead: false, roomId: "123123", sendTime: Date()), width: 350, height: 70)
//    }
//}
