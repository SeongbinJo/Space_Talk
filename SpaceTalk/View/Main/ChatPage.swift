//
//  ChatPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/24.
//

import Foundation
import SwiftUI

struct ChatPage: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    //앱의 생명주기 변화(백그라운드, 액티브 등)
    @Environment(\.scenePhase) var scenePhase
    
    @State var exitRoomAlert: Bool = false
    @Binding var chatListToChatPageActive: Bool
    @Binding var selectChatListData: [String : Any]
    
    var body: some View {
        NavigationView{
                ZStack{
                    VStack{
                        Spacer()
                        GeometryReader{ geometry in
                            ScrollView{
                                ForEach(firestoreViewModel.messages, id: \.id){ message in
                                    MessageBubble(message: message)
                                }
                            }.frame(height: geometry.size.height * 0.9)
                            MessageTextBox( selectChatListData: $selectChatListData)
                        }
                    }
                    .background(.gray)
                }
        }
        .onAppear{
//            loginViewModel.isChatRoomOpenedToggle()
        }
        .toolbarBackground(
                        Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitle(selectChatListData["receiverNickname"] as! String)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.chatListToChatPageActive = false
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
                self.exitRoomAlert = true
            }){
                Label("채팅방 나가기", systemImage: "trash")
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 23))
                .foregroundColor(.black)
        })
        .alert("채팅방 나가기", isPresented: $exitRoomAlert){
            Button("취소", role: .cancel, action: {})
            Button("나가기", role: .destructive, action: {
                firestoreViewModel.exitChatRoom() { exit in
                    if exit {
                        self.chatListToChatPageActive = false
                    }
                }
            })
        } message: {
            Text("채팅방을 나가면 대화내용 및 채팅목록이 삭제됩니다.")
        }
        //ChatPage에서 앱을 백그라운드, 다시 실행 했을 때의 액션.(생명주기)
        .onChange(of: scenePhase){ value in
            switch value{
            case .active:
                print("active")
//                firestoreViewModel.reWriteSelectChatRoomId(){ complete in }
            case .inactive:
                print("inactive")
//                firestoreViewModel.awayFromChatRoom(){ complete in }
            case .background:
                print("background")
//                firestoreViewModel.awayFromChatRoom(){ complete in }
            default:
                print("default!")
            }
        }
        .onDisappear {
            firestoreViewModel.getMessageListener?.remove()
        }
    }
}
