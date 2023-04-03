//
//  LoginSuccess.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct Mainpage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    @State var isTabCliked: Bool = true
    
    var body: some View{
        NavigationView{
            VStack{
                TabView{
                    HomePage(loginViewModel: LoginViewModel(), loginToMainPageActive: $loginToMainPageActive)
                        .tabItem{
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    ChatListpage(loginViewModel: LoginViewModel())
                        .tabItem{
                            Image(systemName: "bubble.left.fill")
                            Text("Chat List")
                        }
                    Text("Setting Page")
                        .tabItem{
                            Image(systemName: "ellipsis")
                            Text("Setting")
                        }
                }
                .accentColor(.brown)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginSuccess_Previews: PreviewProvider {
    static var previews: some View {
        Mainpage(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
    }
}


