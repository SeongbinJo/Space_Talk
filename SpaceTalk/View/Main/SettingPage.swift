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
    
    var body: some View{
        List{
            Button(action: {
                print("로그아웃됨.")
                showLogoutAlert = true
            }){
                Text("로그아웃")
            }
            .alert("Alert Title", isPresented: $showLogoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃") {
                    loginViewModel.logoutUser()
                    loginToMainPageActive = false
                }
            } message: {
                Text("정말로 로그아웃 하시겠습니까?")
            }
        }
    }//body
    
    
    struct SettingPage_Previews: PreviewProvider {
        static var previews: some View {
            SettingPage(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
        }
    }
}
