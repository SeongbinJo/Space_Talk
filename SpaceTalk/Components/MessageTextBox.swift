//
//  MessageTextBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/29.
//

import SwiftUI

struct MessageTextBox: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        HStack{
            TextField("메세지를 입력하세요.", text: $loginViewModel.chatMassageText)
                .textFieldStyle(.roundedBorder)
            Button(action: {}){
                Image(systemName: "flame")
                    .font(.system(size: 35))
            }
        }
        
    }
}

struct MessageTextBox_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextBox(loginViewModel: LoginViewModel())
    }
}
