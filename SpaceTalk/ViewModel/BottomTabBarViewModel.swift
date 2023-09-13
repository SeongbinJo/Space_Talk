//
//  BottomTabBarViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/22.
//

import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import SwiftUI


//MainPage에서 커스텀 하단 탭바의 기능을 담은 ViewModel.
class BottomTabBarViewModel: ObservableObject {
    
    func changeMainView(tabIndex: String, goToMainPage: Binding<Bool>) -> some View{
        switch tabIndex {
        case "home":
            return AnyView(HomePage())
        case "chatList":
            return AnyView(ChatListPage())
        case "setting":
            return AnyView(SettingPage(goToMainPage: goToMainPage))
        default:
            return AnyView(HomePage())
        }
    }
    
}
