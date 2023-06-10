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
                ZStack{
                    Color.gray.ignoresSafeArea()
                    GeometryReader{ geometry in
                        VStack{
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 0.01)
                            
                            ScrollView{
                                ForEach(firestoreViewModel.pushButtonMessages, id: \.id){ pushMessage in
                                    ChatListBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListBoxMessage: pushMessage)
                                        .shadow(color: .black, radius: 4, x: 5, y: 5)
                                        .padding(.vertical, 2)
                                }
                                ForEach(firestoreViewModel.acceptButtonMessages, id: \.id){ acceptMessage in
                                    ChatListBox(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListBoxMessage: acceptMessage)
                                        .shadow(color: .black, radius: 4, x: 5, y: 5)
                                        .padding(.vertical, 2)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .listStyle(.plain)
                            NavigationLink(destination: ChatPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), chatListToChatPageActive: $chatListToChatPageActive), isActive: $chatListToChatPageActive, label: {EmptyView()})
                        }
                    }
                }//zstack
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
