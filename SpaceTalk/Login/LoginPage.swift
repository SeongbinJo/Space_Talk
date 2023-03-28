//
//  LoginPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/28.
//

import Foundation
import SwiftUI

struct LoginPage: View {
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    @State var isCheckboxOn: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing){
            Spacer()
            Spacer()
            ZStack{
                VStack(alignment: .leading){
                    Text("Email")
                        .padding(.top, 10)
                        .padding(.leading, 17)
                    TextField("Enter your Email", text: $userEmail)
                        .padding(.horizontal, 17.0)
                        .textFieldStyle(.roundedBorder)
                    Text("Password")
                        .padding(.top, 10)
                        .padding(.leading, 17)
                    TextField("Enter your Password", text: $userPassword)
                        .padding(.horizontal, 17.0)
                        .padding(.bottom, 13)
                        .textFieldStyle(.roundedBorder)
                    VStack(alignment: .trailing){
                        HStack{
                            Spacer()
                            Button("로그인"){}
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(15)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(-5)
                        Toggle("자동 로그인", isOn: $isCheckboxOn)
                            .frame(width: 140)
                            .padding(.trailing, 15)
                            .padding(.bottom, 5)
                    }
                }
                .background(Color.blue)
                .cornerRadius(20)
            }//zstack
            .padding()
            Button("회원가입"){}
                .foregroundColor(.black)
                .padding(-15)
                .padding(.trailing, 40)
            Spacer()
        }//vstack
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}

