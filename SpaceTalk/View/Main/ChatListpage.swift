//
//  ChatListpage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/03.
//

import Foundation
import SwiftUI

struct ChatListpage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View{
        List{
            Text("chat 1")
            Text("chat 2")
        }
    }//body
}

struct ChatListpage_Previews: PreviewProvider {
    static var previews: some View {
        ChatListpage(loginViewModel: LoginViewModel())
    }
}
