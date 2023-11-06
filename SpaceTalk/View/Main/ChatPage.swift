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
    
    @State var exitRoomAlert : Bool = false
    @State var blockUserAlert : Bool = false
    @Binding var chatListToChatPageActive: Bool
    @Binding var selectChatListData: [String : Any]
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                ZStack {
                    Image("chatlist")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                        .clipped()
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
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
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).height * 0.839)
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                        .foregroundColor(Color.gray.opacity(0.6))
                    VStack{
                        //                    Spacer()
                        ScrollViewReader { proxy in
                            ScrollView {
                                ForEach(firestoreViewModel.messages, id: \.id){ message in
                                    MessageBubble(message: message)
                                }
                            }
                            .frame(height: geometry.size.height * 0.932)
                            .onAppear {
                                withAnimation {
                                    proxy.scrollTo(firestoreViewModel.lastMessageId, anchor: .bottom)
                                }
                            }
                            .onChange(of: firestoreViewModel.lastMessageId) { id in
                                withAnimation {
                                    proxy.scrollTo(id, anchor: .bottom)
                                }
                            }
                        }
                        MessageTextBox(selectChatListData: $selectChatListData)
                            .zIndex(10)
                            .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    }
                }
                
            }
                
        }
        .onAppear{
            
        }
        .toolbarBackground(
            Color.red.opacity(0.5),
                        for: .navigationBar)
//                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitle(selectChatListData["receiverNickname"] as! String)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.chatListToChatPageActive = false
        }){
            HStack{
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.white)
                Text("뒤로가기")
                    .foregroundColor(Color.white)
            }
        })
        .navigationBarItems(trailing: Menu {
            Button(role: .destructive, action: {
                self.blockUserAlert = true
            }) {
                Label("차단하기", systemImage: "exclamationmark.bubble.fill")
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
                .foregroundColor(.white)
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
        .alert("주의!", isPresented: $blockUserAlert){
            Button("취소", role: .cancel, action: {})
            Button("차단하기", role: .destructive, action: {
                firestoreViewModel.getBlockUserUid(nickname: selectChatListData["receiverNickname"] as! String) { blockUID in
                    if blockUID != "error" {
                        firestoreViewModel.blockUser(blockUserUid: blockUID) { complete in
                            if complete {
                                firestoreViewModel.exitChatRoom() { exit in
                                    if exit {
                                        self.chatListToChatPageActive = false
                                    }
                                }
                            }
                        }
                    }else {
                        print("차단 실패 ㅋㅋㅋ")
                    }
                }
                
            })
        } message: {
            Text("상대방을 차단하면 채팅방은 자동으로 삭제됩니다.")
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
