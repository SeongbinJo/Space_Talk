//
//  ChatListpage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/03.
//

import Foundation
import SwiftUI

struct ChatListpage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var chatListToChatPageActive: Bool = false
    

    var body: some View{
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    Color.gray.ignoresSafeArea()
                    ScrollView{
                        ForEach(firestoreViewModel.chatListBoxMessages, id: \.id){ chatList in
                            ChatListBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListBoxMessage: chatList, width: 350, height: 70)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    NavigationLink(destination: ChatPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListToChatPageActive: $chatListToChatPageActive), isActive: $chatListToChatPageActive, label: {EmptyView()})
                }//zstack
            }
        }
        .onAppear{
            
        }
    }//body
}

struct ChatListpage_Previews: PreviewProvider {
    static var previews: some View {
        ChatListpage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()))
    }
}
