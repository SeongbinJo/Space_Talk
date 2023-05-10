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
                    List{
                        //틀 만들어서 찍어내야지.
                        Button(action: {
                            chatListToChatPageActive = true
                        }){
                            HStack{
                                Text("Chat Room 1")
                                    .padding(20)
                                Spacer()
                            }
                        }
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.1)
                        .background(.green)
                        .listRowBackground(Color.clear)
                        .cornerRadius(17)
//                        Button(action: {
//                            firestoreViewModel.notDuplicateRoomId()
//                        }){
//                            Text("중복 없는 RoomId 생성 버튼")
//                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    NavigationLink(destination: ChatPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel)), isActive: $chatListToChatPageActive, label: {EmptyView()})
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
