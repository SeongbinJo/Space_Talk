//
//  ChatListBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/29.
//
//채팅방의 메시지들을 불러올때, Messages Model을 사용하기 때문에,
//ChatListBox에서도 Messages Model을 사용하기로 함.
import SwiftUI

struct ChatListBox: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var chatListBoxMessage: Messages
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack{
            Button(action: {}){
                HStack{
                    VStack(alignment: .leading){
                        HStack{
                            Text(chatListBoxMessage.senderNickName)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Spacer()
                            Text("마지막 대화날짜")
                                .font(.system(size: 13))
                        }
                        HStack{
                            Text(chatListBoxMessage.messageText)
                            Spacer()
                            Text("\(chatListBoxMessage.sendTime)")
                                .font(.system(size: 13))
                        }
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(.yellow)
                    .cornerRadius(15, corners: .allCorners)
                    .frame(width: width, height: height)
                }
            }
        }
    }
}
    
//    struct ChatListBox_Previews: PreviewProvider {
//        static var previews: some View {
//            ChatListBox(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), chatListBoxMessage: Messages(messageId: "asdf", roomId: "123", messageText: "hihi", sendTime: Date(), senderId: "sender", receiverId: "receiver", isRead: false, senderNickName: "나다이씹샊"), width: 340, height: 70)
//        }
//    }
