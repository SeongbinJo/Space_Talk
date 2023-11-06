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
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        Rectangle()
                            .frame(width: geometry.size.width * 1.0, height: 2)
                            .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                        HStack(spacing: 0){
                            Button(action:{
                                withAnimation {
                                    tabIndex = "home"
                                }
                            }){
                                Image(systemName: self.tabIndex == "home" ? "house.fill" : "house")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(self.tabIndex == "home" ? 1.1 : 0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                            Rectangle()
                                .frame(width: 2, height: geometry.size.height * 0.065)
                                .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                            Button(action:{
                                withAnimation {
                                    tabIndex = "chatList"
                                }
                            }){
                                Image(systemName: self.tabIndex == "chatList" ? "bubble.fill" : "bubble.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(self.tabIndex == "chatList" ? 1.1 : 0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                            Rectangle()
                                .frame(width: 2, height: geometry.size.height * 0.065)
                                .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                            Button(action:{
                                withAnimation {
                                    tabIndex = "setting"
                                }
                            }){
                                Image(systemName: self.tabIndex == "setting" ? "ellipsis.circle.fill" : "ellipsis.circle")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                    .scaleEffect(self.tabIndex == "setting" ? 1.1 : 0.9)
                            }
                            .frame(width: geometry.size.width / 3)
                        }//hstack
                        .frame(height: geometry.size.height * 0.085)
                        .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0))) 
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            print("MainPage가 실행되었습니다!")
            //현재 유저 정보(닉네임,이메일) 불러오기
            loginViewModel.currentUserInformation() { complete in
                if complete {
                    print("현재 유저정보(닉네임, 이메일) 불러오기 완료.")
                    firestoreViewModel.nickname = loginViewModel.currentNickname
                    loginViewModel.testfunc()
                    firestoreViewModel.getFirstMessage()
                    firestoreViewModel.currentChatList()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
