//
//  SignUpPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/28.
//

import Foundation
import SwiftUI

struct SignUpPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Binding var loginToSignUpPageActive: Bool
    
    @State var signUpNickname: String = ""
    @State var signUpEmail: String = ""
    @State var signUpPassword: String = ""
    @State var signUpPasswordCheck: String = ""
    
    @State var emailCheck = false
    @State var pwdCheck = false
    @State var pwdSecondCheck = false
    
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
                            .autocapitalization(.none)
                        Button("중복확인"){}
                            .padding(6)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(11)
                            .padding(.trailing, 8)
                    }
                    HStack{
                        Text("이메일")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    VStack(alignment: .leading){
                        HStack{
                            TextField("사용할 이메일을 입력하세요.", text: $signUpEmail)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .padding(.trailing, 87)
                                .autocapitalization(.none)
                        }
                        .onChange(of: signUpEmail){ signUpEmail in
                            emailCheck = loginViewModel.isValidEmail(email: signUpEmail)
                            print(emailCheck)
                        }
                        if signUpEmail.count > 0 {
                            if loginViewModel.isValidEmail(email: signUpEmail) == false{
                                Text("이메일 형식이 맞지 않습니다.")
                                    .padding(.leading, 15)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .padding(.bottom, 1)
                            }
                        }
                    }
                    HStack{
                        Text("비밀번호")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    VStack(alignment: .leading){
                        HStack{
                            TextField("비밀번호를 입력하세요.(8자 이상)", text: $signUpPassword)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .padding(.trailing, 87)
                                .autocapitalization(.none)
                        }
                        .onChange(of: signUpPassword){ signUpPassword in
                            pwdCheck = loginViewModel.isValidPassword(password: signUpPassword)
                        }
                        if signUpPassword.count > 0 {
                            if loginViewModel.isValidPassword(password: signUpPassword) == false{
                                Text("8자리 이상 입력해주세요.")
                                    .padding(.leading, 15)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .padding(.bottom, 1)
                            }
                        }
                    }
                    HStack{
                        Text("비밀번호 확인")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    VStack(alignment: .leading){
                        HStack{
                            TextField("다시 한 번 입력하세요.", text: $signUpPasswordCheck)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .padding(.trailing, 90)
                                .autocapitalization(.none)
                        }
                        .onChange(of: signUpPasswordCheck){ signUpPasswordCheck in
                            pwdSecondCheck = loginViewModel.isSamePassword(password: signUpPassword, passwordCheck: signUpPasswordCheck)
                        }
                        //비밀번호 확인 -> 1자라도 입력시 비밀번호 일치, 불일치 여부 출력
                        if signUpPasswordCheck.count > 0 {
                            if loginViewModel.isSamePassword(password: signUpPassword, passwordCheck: signUpPasswordCheck){
                                Text("비밀번호가 일치합니다.")
                                    .padding(.leading, 15)
                                    .font(.system(size: 13))
                                    .foregroundColor(.blue)
                            }else{
                                Text("비밀번호가 틀립니다.")
                                    .padding(.leading, 15)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button("가입하기"){
                    loginViewModel.registerUser(email: signUpEmail, password: signUpPasswordCheck){ success in
                        if success {
                            loginToSignUpPageActive = false
                        }
                    }
                }
                    .padding(10)
                    .background(emailCheck&&pwdCheck&&pwdSecondCheck ? .blue : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.top, 20)
                    .disabled(emailCheck&&pwdCheck&&pwdSecondCheck ? false : true)
                Spacer()
            }

        }
        .navigationBarTitle("회원가입")
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(loginViewModel: LoginViewModel(), loginToSignUpPageActive: .constant(true))
    }
}
