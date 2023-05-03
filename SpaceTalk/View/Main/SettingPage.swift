//
//  SettingPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/06.
//

import Foundation
import SwiftUI

struct SettingPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    @State var showLogoutAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    
    var body: some View{
        ZStack{
//            Color.gray.ignoresSafeArea()
            List{
                Button(action: {
                    showLogoutAlert = true
                }){
                    Text("로그아웃")
                }
                .alert("로그아웃", isPresented: $showLogoutAlert) {
                    Button("취소", role: .cancel) {}
                    Button("로그아웃") {
                        loginViewModel.logoutUser()
                        loginToMainPageActive = false
                        print(loginToMainPageActive)
                    }
                } message: {
                    Text("정말로 로그아웃 하시겠습니까?")
                }
                .foregroundColor(.black)
                Button(action: {
                    showDeleteAlert = true
                }){
                    Text("계정탈퇴")
                }
                .alert("주의!", isPresented: $showDeleteAlert) {
                    Button("취소", role: .cancel) {}
                    Button("계정탈퇴") {
                        loginViewModel.deleteUser()
                        loginToMainPageActive = false
                        print(loginToMainPageActive)
                    }
                } message: {
                    Text("정말로 계정탈퇴 하시겠습니까?")
                }
                .foregroundColor(.red)
            }
        }
    }//body
    
    
    struct SettingPage_Previews: PreviewProvider {
        static var previews: some View {
            SettingPage(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
        }
    }
}
