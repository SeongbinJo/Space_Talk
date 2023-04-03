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
    
    @State var isTabCliked: Bool = true
    
    var body: some View{
        NavigationView{
            TabView{
                HomePage(loginViewModel: LoginViewModel(), loginToMainPageActive: $loginToMainPageActive)
                    .tabItem{
                        Image(systemName: isTabCliked ? "bubble.left.fill" : "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                Text("Chat List")
                    .tabItem{
                        Image(systemName: "bubble.left.fill")
                        Text("Chat List")
                    }
                    .tag(1)
                Text("Setting Page")
                    .tabItem{
                        Image(systemName: "ellipsis")
                        Text("Setting")
                    }
                    .tag(2)
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


