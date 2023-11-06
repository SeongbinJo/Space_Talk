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
            GeometryReader{ geometry in
                Image("chatlist")
                    .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                                .clipped()
                                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                                .zIndex(0)
                VStack{
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
                .zIndex(2)
                VStack {
                    Text("Background Author - Alvish Baldha")
                        .font(.system(size: geometry.size.width * 0.02))
                        .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                    Text("Original Link - https://www.figma.com/community/file/786982732117165587/space")
                        .font(.system(size: geometry.size.width * 0.02))
                        .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                        .accentColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                    Text("Licensed under CC BY 4.0")
                        .font(.system(size: geometry.size.width * 0.02))
                        .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                }
                .zIndex(1)
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).height * 0.839)
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
