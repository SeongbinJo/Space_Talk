//
//  ContentView.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var loginViewModel: LoginViewModel
    
    var body: some View {
        if loginViewModel.currentUser == nil {
            LoginPage(loginViewModel: LoginViewModel())
        }else{
            MainPage(loginViewModel: loginViewModel, loginToMainPageActive: .constant(true))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginViewModel: LoginViewModel())
    }
}
