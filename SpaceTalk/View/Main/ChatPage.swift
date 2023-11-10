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
    
    @State var isImage : Bool = false
    @State var getImage : UIImage? = nil
    
    @State var getReady : Bool = false
    
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                Rectangle()
                                    .frame(height: geometry.size.height * 0.003)
                                    .foregroundColor(Color.clear)
                                ForEach(firestoreViewModel.messages, id: \.id){ message in
                                    MessageBubble(message: message, getReady: $getReady)
                                }
                                .onAppear {
//                                    withAnimation {
                                        proxy.scrollTo("bottom", anchor: .bottom)
//                                    }
                                }
                                Rectangle()
                                    .frame(height: geometry.size.height * 0.0003)
                                    .foregroundColor(Color.clear)
                                    .id("bottom")
                            }
                            //새로운 메시지가 생길 때 그 메시지 위치로 스크롤 이동
                            .onChange(of: firestoreViewModel.lastMessageId) { id in
                                withAnimation {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                            //MessageBubble의 이미지가 로딩되면 메시지 크기가 바뀌는데 이 크기를 담는 geoHeight, textHeight의 합을 messageHeight로 담고 messageHeight의 값이 변하면(= geo, text중의 하나 이상은 값이 바뀌었다는 뜻) 이를 감지하여 맨 밑으로 스크롤.
                            .onChange(of: firestoreViewModel.messageHeight) { id in
                                        withAnimation {
                                            proxy.scrollTo("bottom", anchor: .bottom)
                                        }
                                }
                        }
                        MessageTextBox(selectChatListData: $selectChatListData, getImage: $getImage, isImage: $isImage)
                            .frame(height: geometry.size.height * 0.1)
                            .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                        
                    }
                    .background(
                        ZStack {
                            Image("chatlist")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                                            .clipped()
                                            .ignoresSafeArea(.keyboard)
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                                .foregroundColor(Color.gray.opacity(0.6))
                            VStack {
                                Text("Background Author - Alvish Baldha")
                                    .font(.system(size: geometry.size.width * 0.02))
                                Text("Original Link - https://www.figma.com/community/file/786982732117165587/space")
                                    .font(.system(size: geometry.size.width * 0.02))
                                Text("Licensed under CC BY 4.0")
                                    .font(.system(size: geometry.size.width * 0.02))
                                }
                            .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 0.6)))
                            .accentColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 0.6)))
                                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).height * 0.97)
                        }
                    )
                    //이미지 선택 미리보기
                                    if self.isImage {
                                            ZStack(alignment: .topTrailing){
                                                ZStack{
                                                    Rectangle()
                                                        .frame(width: geometry.size.width * 0.7, height: self.getImage == nil ? geometry.size.width * 0.7 : self.getImage!.size.height * (geometry.size.width * 0.7/self.getImage!.size.width))
                                                        .foregroundColor(Color.clear)
                                                        Rectangle()
                                                            .frame(width: geometry.size.width * 0.65, height: self.getImage == nil ? geometry.size.width * 0.65 : self.getImage!.size.height * (geometry.size.width * 0.65/self.getImage!.size.width))
                                                            .foregroundColor(Color(UIColor.lightGray))
                                                            .overlay(
                                                                self.getImage != nil ?
                                                                Image(uiImage: getImage!)
                                                                    .resizable()
                                                                : Image(systemName: "xmark")
                                                            )
                                                            .cornerRadius(10, corners: .allCorners)
                                                }
                                                .shadow(color: .black, radius: 10, x: 5, y: 5)
                                                .padding(.leading, geometry.size.width * 0.03)
                                                    Button(action: {
                                                        self.getImage = nil
                                                        self.isImage = false
                                                    }){
                                                        Circle()
                                                            .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                                                            .foregroundColor(Color.white)
                                                            .zIndex(1)
                                                            .overlay(Image(systemName: "xmark"))
                                                    }
                                            }
                                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                                        }
                }
            }
        }
        .onAppear{
            
        }
        .toolbarBackground(
                    Color.gray.opacity(0.3),
                                for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
    }
}
