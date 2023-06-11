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
    
    //해당 채팅방으로 이동 위한 변수.
    @Binding var chatListToChatPageActiveAccept: Bool
    
    var chatListBoxMessage: PushButtonMessages
    
    @State var geometryHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Button(action: {
//                    firestoreViewModel.saveClickChatListData(messageid: chatListBoxMessage.messageId, roomid: chatListBoxMessage.roomId, messagetext: chatListBoxMessage.messageText, sendtime: chatListBoxMessage.sendTime, senderid: chatListBoxMessage.senderId, receiverid: chatListBoxMessage.receiverId, isread: chatListBoxMessage.isRead, sendernickname: chatListBoxMessage.senderNickName, receivernickname: chatListBoxMessage.receiverNickName, firstsenderid: chatListBoxMessage.firstSenderId, firstreceiverid: chatListBoxMessage.firstReceiverId, isavailable: chatListBoxMessage.isAvailable)
                    chatListToChatPageActiveAccept = true
                }){
                    //geometryreader 사용으로 겹침방지 위해 넣은 text
                    Text("")
                        .padding()
                        .background{
                            GeometryReader{ geo in
                                Text("")
                                    .onAppear{
                                        geometryHeight = geo.size.height * 2.3
                                    }
                                    .frame(width: 0)
                            }
                        }
                        .frame(width: 0)
                    Spacer()
                        HStack{
                            VStack(alignment: .leading){
                                HStack{
                                    Text(loginViewModel.currentUser?.uid == chatListBoxMessage.senderId ? "\(chatListBoxMessage.receiverNickName)님과의 대화" : "\(chatListBoxMessage.senderNickName)님과의 대화")
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(chatListBoxMessage.formattedDay)")
                                        .font(.system(size: 13))
                                }
                                HStack{
                                    Text(chatListBoxMessage.messageText)
                                    Spacer()
                                    Text("\(chatListBoxMessage.formattedTime)")
                                        .font(.system(size: 13))
                                }
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(.white)
                            .cornerRadius(15, corners: .allCorners)
                            .frame(width: geometry.size.width * 0.95)
                        }
                    Spacer()
                }
            }
        }
        .frame(height: geometryHeight)
    }
}
    
//    struct ChatListBox_Previews: PreviewProvider {
//        static var previews: some View {
//            ChatListBox(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), chatListBoxMessage: Messages(messageId: "asdf", roomId: "123", messageText: "hihi", sendTime: Date(), senderId: "sender", receiverId: "receiver", isRead: false, senderNickName: "나다이씹샊"), width: 340, height: 70)
//        }
//    }
