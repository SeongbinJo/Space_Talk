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
        GeometryReader{ geomtry in
            VStack{
                HStack{
                    Button(action: {}){
                        Image(systemName: true ? "plus" : "multiply")
                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .font(.system(size: geomtry.size.width * 0.085))
                        
                    }
                    TextField("메세지를 입력하세요.", text: $loginViewModel.chatMassageText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: geomtry.size.width * 0.05))
                        .cornerRadius(13, corners: .allCorners)
                    Button(action: {}){
                        Image(systemName: true ? "arrow.up.circle" : "arrow.up.circle.fill")
                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .font(.system(size: geomtry.size.width * 0.085))
                    }
                }
                .padding(.horizontal, geomtry.size.width * 0.03)
                .padding(.top, 10)
                .padding(.bottom, geomtry.size.height * 0.12)
                .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                .position(x: geomtry.frame(in: .local).midX, y: geomtry.frame(in: .local).maxY)
            }
        }
    }
}

struct MessageTextBox_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextBox(loginViewModel: LoginViewModel())
    }
}
