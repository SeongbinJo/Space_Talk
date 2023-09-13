//
//  MainPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/22.
//

import Foundation
import SwiftUI

struct MainPage: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @StateObject var tapBarViewModel = BottomTabBarViewModel()
    
    @State var tabIndex: String = "home"
    
    @Binding var goToMainPage: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                tapBarViewModel.changeMainView(tabIndex: self.tabIndex, goToMainPage: $goToMainPage)
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack(spacing: 0){
                            Button(action:{
                                tabIndex = "home"
                            }){
                                Image(systemName: "house")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                            Button(action:{
                                tabIndex = "chatList"
//                                firestoreViewModel.currentChatList()
                            }){
                                Image(systemName: "bubble.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                            Button(action:{
                                tabIndex = "setting"
                            }){
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                        }//hstack
                        .frame(height: geometry.size.height * 0.1)
                        .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0))) 
                    }
                }
            }
        }
        .onAppear {
            print("MainPage가 실행되었습니다!")
            //현재 유저 정보(닉네임,이메일) 불러오기
            loginViewModel.currentUserInformation() { complete in
                if complete {
                    print("현재 유저정보(닉네임, 이메일) 불러오기 완료.")
                    firestoreViewModel.nickname = loginViewModel.currentNickname
                    firestoreViewModel.testfunc()
                    loginViewModel.testfunc()
                    firestoreViewModel.getFirstMessage()
                    firestoreViewModel.currentChatList()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
}

//텍스트필드 외 모든 부분을 클릭하면 키보드가 dismiss되게끔.
extension View{
    func hideKeyboard() {
           let resign = #selector(UIResponder.resignFirstResponder)
           UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
       }
}

//struct MainPage_Previews: PreviewProvider {
//    static var previews: some View {
//        MainPage()
//    }
//}
