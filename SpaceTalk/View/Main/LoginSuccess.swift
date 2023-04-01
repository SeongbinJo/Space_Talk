//
//  LoginSuccess.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginSuccess: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    var body: some View{
        NavigationView{
            VStack{
                Text("success!!!!!")
                Button(action: {
                    loginViewModel.logoutUser()
                    loginToMainPageActive = false
                }, label: {
                    Text("로그아웃")
                })
                Text("uid : \(loginViewModel.currentUser?.uid ?? "비로그인")")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginSuccess_Previews: PreviewProvider {
    static var previews: some View {
        LoginSuccess(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
    }
}


