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
    
    var body: some View{
        NavigationView{
                ZStack{
                    VStack{
                        Spacer()
                        GeometryReader{ geometry in
                            ScrollView{
                                ForEach(firestoreViewModel.messages, id: \.roomId){ message in
                                    MessageBubble(message: message)
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
        }
        .onDisappear{
            loginViewModel.isChatRoomOpenedToggle()
        }
        .toolbarBackground(
                        Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitle("상대방 닉네임", displayMode: .inline)
        .navigationBarItems(trailing: Menu {
            Button(role: .destructive, action: {}) {
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

struct ChatPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatPage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()))
        }

    }
}
