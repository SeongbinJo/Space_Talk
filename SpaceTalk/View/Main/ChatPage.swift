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
    
    var messageArray = ["hello!", "hi!", "how are you?", "i'm gooood!", "what are you doing now? 123123", "i'm studying SwiftU123123123123I.", "wow! isn't it hard?", "yeah, but it's fun", "oh, that's cool", "when will you123123123123123 go to home?", "hmm.. i don't k12312312312213now", "oh, okay ha123123123ve fun!", " a;slkdfja;lkwje;fl12;3"]
    
    var body: some View{
        NavigationView{
            GeometryReader{ geometry in
                VStack{
                    ScrollView{
                        ForEach(messageArray, id: \.self){
                            text in MessageBubble(message: Message(id: "1234", msgText: text, isMsgReceived: false, timeStamp: Date()))
                        }
                    }
                }
                .background(.gray)
            }
        }
        .onAppear{
            loginViewModel.isChatRoomOpen = true
            print(loginViewModel.isChatRoomOpen)
        }
        .onDisappear{
            loginViewModel.isChatRoomOpen = false
            print(loginViewModel.isChatRoomOpen)
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
            Button(action: {}) {
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
            ChatPage(loginViewModel: LoginViewModel())
        }
    }
}
