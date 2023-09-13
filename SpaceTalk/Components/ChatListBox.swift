//
//  ChatListBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/24.
//

import Foundation
import SwiftUI

struct ChatListBox: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    //해당 채팅방으로 이동 위한 변수.
    @Binding var chatListToChatPageActive: Bool
    
    @Binding var selectChatListData: [String : Any]
    
    var chatListBoxMessage: PushButtonMessages
    
    //상대방이 채팅방을 나갔을경우 팝업창.
    @State var chatRoomExitAlert: Bool = false
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Button(action: {
                    firestoreViewModel.currentRoomId = chatListBoxMessage.roomId
                    //해당 채팅방의 isExit을 체크해서 참이면 alert창 띄우고 삭제, 거짓이면 chatpage 이동.
                    firestoreViewModel.isExitBool() { isExit in
                        if isExit {
                            self.chatRoomExitAlert = true
                        }
                        else {
                            firestoreViewModel.getMessages()
                            firestoreViewModel.getNickname(uid: chatListBoxMessage.firstReceiverId) { complete in
                                if complete {
                                    self.selectChatListData = ["isAvailable" : chatListBoxMessage.isAvailable, "receiverNickname" : firestoreViewModel.nickname]
                                    self.chatListToChatPageActive = true
                                }
                            }
                        }
                    }
                }){
                    //geometryreader 사용으로 겹침방지 위해 넣은 text
                    Text("")
                        .padding()
                        .frame(width: 0)
                    Spacer()
                        HStack{
                            VStack(alignment: .leading){
                                HStack{
                                    Text(firestoreViewModel.currentUser?.uid == chatListBoxMessage.firstSenderId ? "111님과의 대화" : "222님과의 대화")
                                        .font(.system(size: geometry.size.height * 0.25))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(chatListBoxMessage.formattedDay)")
                                        .font(.system(size: geometry.size.height * 0.15))
                                }
                                HStack{
                                    Text(chatListBoxMessage.messageText)
                                    Spacer()
                                    Text("\(chatListBoxMessage.formattedTime)")
                                        .font(.system(size: geometry.size.height * 0.15))
                                }
                            }
                            .foregroundColor(.black)
                            .padding(geometry.size.height * 0.16)
                            .background(.white)
                            .cornerRadius(15, corners: .allCorners)
                            .frame(width: geometry.size.width * 0.95)
                        }
                    Spacer()
                }
                .alert("이런!", isPresented: $chatRoomExitAlert){
                    Button("확인") {
                        firestoreViewModel.deleteChatRoom()
                    }
                } message: {
                    Text("상대방이 채팅방을 나갔습니다.")
                }
            }
        }
    }
}
