//
//  ContentView.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginPage(loginViewModel: LoginViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
