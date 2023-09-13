//
//  ContentView.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    var body: some View {
        if loginViewModel.currentUser == nil {
            LoginPage()
        }else{
            MainPage(goToMainPage: .constant(true))
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(LoginViewModel())
//    }
//}
