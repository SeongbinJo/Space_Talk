//
//  SignUpPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/28.
//

import Foundation
import SwiftUI

struct SignUpPage: View {
    @State var signUpNickname: String = ""
    @State var signUpEmail: String = ""
    @State var signUpPassword: String = ""
    @State var signUpPasswordCheck: String = ""
    
    var body: some View {
        NavigationView{
            VStack{
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(height: 1)
                    .padding(.vertical, 15)
                VStack(){
                    HStack{
                        Text("닉네임")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        TextField("사용할 닉네임을 입력하세요.", text: $signUpNickname)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 15)
                        Button("중복확인"){}
                            .padding(6)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(11)
                            .padding(.trailing, 15)
                        
                    }
                    HStack{
                        Text("이메일")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        TextField("사용할 이메일을 입력하세요.", text: $signUpEmail)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 15)
                        Button("이메일 인증"){}
                            .padding(6)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(11)
                            .padding(.trailing, 15)
                        
                    }
                    HStack{
                        Text("비밀번호")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        TextField("비밀번호를 입력하세요.", text: $signUpPassword)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 15)
                            .padding(.trailing, 114)
                    }
                    HStack{
                        Text("비밀번호 확인")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        TextField("다시 한 번 입력하세요.", text: $signUpPasswordCheck)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 15)
                            .padding(.trailing, 114)
                    }
                }
                Button("회원가입"){}
                    .padding(10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.top, 20)
                Spacer()
            }

        }
        .navigationBarTitle("회원가입")
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage()
    }
}
