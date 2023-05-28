//
//  ChatListBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/29.
//

import SwiftUI

struct ChatListBox: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack{
            Button(action: {}){
                HStack{
                    VStack(alignment: .leading){
                        HStack{
                            Text("(상대방 닉네임)")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Spacer()
                            Text("마지막 대화날짜")
                                .font(.system(size: 13))
                        }
                        HStack{
                            Text("마지막 메시지")
                            Spacer()
                            Text("2023.05.31")
                                .font(.system(size: 13))
                        }
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(.yellow)
                    .cornerRadius(15, corners: .allCorners)
                    .frame(width: width, height: height)
                }
            }
        }
    }
}
    
    struct ChatListBox_Previews: PreviewProvider {
        static var previews: some View {
            ChatListBox(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), width: 340, height: 70)
        }
    }
