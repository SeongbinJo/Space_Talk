//
//  ChatPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/06.
//

import Foundation
import SwiftUI

struct ChatPage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var chatListToChatPageActiveAccept: Bool
    
    @Binding var selectChatListData: [String : Any]
    
    var body: some View{
        NavigationView{
                ZStack{
                    VStack{
                        Spacer()
                        GeometryReader{ geometry in
                            ScrollView{
                                ForEach(firestoreViewModel.messages, id: \.id){ message in
                                    MessageBubble(loginViewModel: loginViewModel, message: message)
                                }
                            }.frame(height: geometry.size.height * 0.9)
                            MessageTextBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel))
                        }
                    }
                    .background(.gray)
                }
        }
        .onAppear{
            loginViewModel.isChatRoomOpenedToggle()
            print("현재 선택한 채팅방의 roomid는 \(firestoreViewModel.selectChatRoomId)입니다. 채팅방.")
        }
        .toolbarBackground(
                        Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitle(String(describing: selectChatListData["nickname"]!))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            chatListToChatPageActiveAccept = false
            loginViewModel.isChatRoomOpenedToggle()
//            print("chatListToChatPageActive 는 현재 : \(chatListToChatPageActive)입니다.")
        }){
            HStack{
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        .navigationBarItems(trailing: Menu {
            Button(role: .destructive, action: {
//                print(firestoreViewModel.clickChatListData)
            }) {
                Label("신고하기", systemImage: "exclamationmark.bubble.fill")
            }
            .foregroundColor(.red)
            Button(action: {
                firestoreViewModel.deleteMessagesFromFirestore()
            }) {
                Label("채팅방 나가기", systemImage: "trash")
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 23))
                .foregroundColor(.black)
        })
    }//body
}

//struct ChatPage_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView{
//            ChatPage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), chatListToChatPageActive: .constant(false))
//        }
//
//    }
//}
