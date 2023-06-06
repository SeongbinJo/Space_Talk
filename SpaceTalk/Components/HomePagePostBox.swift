//
//  HomePagePostBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/28.
//

import SwiftUI

struct HomePagePostBox: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var postBoxZindex: Double
    
    var body: some View {
        GeometryReader{ geomtry in
            ZStack(alignment: .topTrailing){
                VStack{
                        Text("새로 온 무전")
                            .padding(.top, geomtry.size.height * 0.015)
                    ScrollView{
                        ForEach(firestoreViewModel.newmessages, id: \.messageId){ newmessage in
                            HomePageNewMessage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), newMessage: newmessage, width: geomtry.size.width * 0.8, height: geomtry.size.height * 0.1)
                        }
                    }
                }
                .frame(width: geomtry.size.width * 0.8)
                Button(action: {
                    postBoxZindex = -1
                }){
                    Text("닫기")
                        .foregroundColor(.black)
                        .padding(.top, geomtry.size.height * 0.015)
                        .padding(.trailing, 5)
                }
            }
            .frame(width: geomtry.size.width * 0.85, height: geomtry.size.height * 0.5)
            .background(Color(UIColor(r: 94, g: 94, b: 94, a: 1)))
            .cornerRadius(20, corners: .allCorners)
            .position(x: geomtry.frame(in: .local).midX, y: geomtry.frame(in: .local).midY)
        }
    }
}

struct HomePagePostBox_Previews: PreviewProvider {
    static var previews: some View {
        HomePagePostBox(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), postBoxZindex: .constant(-1))
    }
}
