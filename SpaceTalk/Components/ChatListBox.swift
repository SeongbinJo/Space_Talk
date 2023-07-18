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

    @Binding var selectChatListData: [String : Any]
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Button(action: {
                    let selectChatNickName = loginViewModel.currentUser?.uid == chatListBoxMessage.firstSenderId ? chatListBoxMessage.receiverNickName : chatListBoxMessage.senderNickName
                    selectChatListData = ["roomid" : chatListBoxMessage.roomId, "nickname" : selectChatNickName, "isavailable" : chatListBoxMessage.isAvailable]
                    //클릭한 채팅방의 roomid를 firestore에 저장함. 저장이 완료되면 채팅페이지로 넘어감.
                            firestoreViewModel.selectRoomIdSave(roomid: chatListBoxMessage.roomId){
                                completion in
                                if completion{
                                    firestoreViewModel.getMessages()
                                    chatListToChatPageActiveAccept = true
                                }
                            }

//                    firestoreViewModel.selectChatRoomId = chatListBoxMessage.roomId
//                    $firestoreViewModel.selectChatRoomId = Binding(chatListBoxMessage.roomId)
//                    print("현재 클릭한 채팅방의 roomid: \(firestoreViewModel.selectChatRoomId)")
//                    firestoreViewModel.getMessages()
                }){
                    //geometryreader 사용으로 겹침방지 위해 넣은 text
                    Text("")
                        .padding()
                        .frame(width: 0)
                    Spacer()
                        HStack{
                            VStack(alignment: .leading){
                                HStack{
                                    Text(loginViewModel.currentUser?.uid == chatListBoxMessage.firstSenderId ? "\(chatListBoxMessage.receiverNickName)님과의 대화" : "\(chatListBoxMessage.senderNickName)님과의 대화")
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
    }
}
    
//    struct ChatListBox_Previews: PreviewProvider {
//        static var previews: some View {
//            ChatListBox(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), chatListBoxMessage: Messages(messageId: "asdf", roomId: "123", messageText: "hihi", sendTime: Date(), senderId: "sender", receiverId: "receiver", isRead: false, senderNickName: "나다이씹샊"), width: 340, height: 70)
//        }
//    }
