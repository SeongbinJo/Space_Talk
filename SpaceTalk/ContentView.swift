//
//  ContentView.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        if loginViewModel.currentUser == nil {
            LoginPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel))
        }else{
            MainPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), loginToMainPageActive: .constant(true))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginViewModel: LoginViewModel())
    }
}
