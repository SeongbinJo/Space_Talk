//
//  ChatListpage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/03.
//
//.shadow(color: .black, radius: 4, x: 5, y: 5)
//.padding(.vertical, 2)


import Foundation
import SwiftUI

struct ChatListpage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel

    //해당 채팅방으로 이동 위한 변수.

    @State var chatListToChatPageActiveAccept: Bool = false
    
    @State var selectChatListData: [String : Any] = ["roomid" : "testroomid", "nickname" : "testnickname"]
    
    var body: some View{
        NavigationView{
                ZStack{
                    Color.gray.ignoresSafeArea()
                    GeometryReader{ geometry in
                        VStack{
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 0.01)
                            ScrollView{
                                //push
                                ForEach(firestoreViewModel.pushButtonMessages, id: \.id){ pushMessage in
                                    ChatListBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListToChatPageActiveAccept: $chatListToChatPageActiveAccept, chatListBoxMessage: pushMessage, selectChatListData: $selectChatListData)
                                        .shadow(color: .black, radius: 4, x: 5, y: 5)
                                        .padding(.vertical, 2)
                                }
                                ForEach(firestoreViewModel.acceptButtonMessages, id: \.id){ acceptMessage in
                                    ChatListBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListToChatPageActiveAccept: $chatListToChatPageActiveAccept, chatListBoxMessage: acceptMessage, selectChatListData: $selectChatListData)
                                        .shadow(color: .black, radius: 4, x: 5, y: 5)
                                        .padding(.vertical, 2)
                                }
                            }
                            .background{
                                NavigationLink(destination: ChatPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListToChatPageActiveAccept: $chatListToChatPageActiveAccept, selectChatListData: $selectChatListData), isActive: $chatListToChatPageActiveAccept, label: {EmptyView()})
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                }//zstack
        }
        .onAppear{
//            print("현재 선택한 채팅방의 roomid는 \(firestoreViewModel.selectChatRoomId)입니다. 채팅방.")
        }
    }//body
}

//struct ChatListpage_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatListpage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()))
//    }
//}


