//
//  ChatListPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/23.
//

import Foundation
import SwiftUI

struct ChatListPage: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @State var chatListToChatPageActive: Bool = false
    
    @State var selectChatListData: [String : Any] = ["isAvailable" : false, "receiverNickname" : ""]
    
    var body: some View {
        ZStack{
            Color.gray.ignoresSafeArea()
            GeometryReader{ geometry in
                VStack{
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 0.01)
                    ScrollView{
                        ForEach(firestoreViewModel.pushButtonChatRoom, id: \.id) { pushMessage in
                            ChatListBox(chatListToChatPageActive: $chatListToChatPageActive, selectChatListData: $selectChatListData, chatListBoxMessage: pushMessage)
                                .frame(height: geometry.size.height * 0.1)
                                .shadow(color: .black, radius: 4, x: 5, y: 5)
                        }
                        ForEach(firestoreViewModel.acceptButtonChatRoom, id: \.id) { acceptMessage in
                            ChatListBox(chatListToChatPageActive: $chatListToChatPageActive, selectChatListData: $selectChatListData, chatListBoxMessage: acceptMessage)
                                .frame(height: geometry.size.height * 0.1)
                                .shadow(color: .black, radius: 4, x: 5, y: 5)
                        }
                    }
                    .background{
                        NavigationLink(destination: ChatPage(chatListToChatPageActive: $chatListToChatPageActive, selectChatListData: $selectChatListData), isActive: $chatListToChatPageActive, label: {EmptyView()})
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }//zstack
        .onAppear {
        }
    }
}

struct ChatListPage_Previews: PreviewProvider {
    static var previews: some View {
        ChatListPage()
    }
}
