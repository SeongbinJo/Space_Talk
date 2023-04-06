//
//  ChatPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/06.
//

import Foundation
import SwiftUI

struct ChatPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    
    var body: some View{
        NavigationView{
            Text("hi")
        }
    }//body
}

struct ChatPage_Previews: PreviewProvider {
    static var previews: some View {
        ChatPage(loginViewModel: LoginViewModel())
    }
}
