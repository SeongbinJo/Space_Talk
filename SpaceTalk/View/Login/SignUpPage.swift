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
    
    var body: some View {
        NavigationView{
            VStack{
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(height: 1)
                    .padding(.vertical, 15)
                VStack(alignment: .leading){
                    HStack{
                        Text("닉네임")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        TextField("사용할 닉네임을 입력하세요.", text: $loginViewModel.signUpNickname)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading, 15)
                            .autocapitalization(.none)
                        Button(action: {
                            loginViewModel.isNickNameAlreadyUsed(){ isComplete in
                                loginViewModel.isAlreadyNickName = isComplete
                                loginViewModel.showNickNameResult = true
                            }
                        }){
                            Text("중복확인")
                        }
                            .padding(6)
                            .foregroundColor(.white)
                            .background(loginViewModel.signUpNickname.count == 0 || loginViewModel.isValidNickName() == false ? .gray : .blue)
                            .cornerRadius(11)
                            .padding(.trailing, 8)
                            .disabled(loginViewModel.signUpNickname.count == 0 || loginViewModel.isValidNickName() == false ? true : false)
                            .alert("확인", isPresented: $loginViewModel.showNickNameResult){
                                Button("확인", role: .cancel){
                                    if loginViewModel.isAlreadyNickName{
                                        loginViewModel.signUpNickname = ""
                                    }
                                }
                            } message: {
                                Text(loginViewModel.isAlreadyNickName ? "이미 사용중인 닉네임 입니다." : "사용가능한 닉네임 입니다.")
                            }
                    }
                    .onChange(of: loginViewModel.signUpNickname){ signUpNickName in
                        loginViewModel.nickNameCheck = loginViewModel.isValidNickName()
                    }
                    if loginViewModel.signUpNickname.count > 0 {
                        if loginViewModel.isValidNickName() == false{
                            Text("공백과 특수문자를 제외한 1-10 글자를 입력해주세요.")
                                .padding(.leading, 15)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.bottom, 1)
                        }
                    }
                    HStack{
                        Text("이메일")
                            .padding(.leading, 15)
                        Text("(메일 인증을 위해 사용중인 이메일을 입력해주세요.)")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    VStack(alignment: .leading){
                        HStack{
                            TextField("사용할 이메일을 입력하세요.", text: $loginViewModel.signUpEmail)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .autocapitalization(.none)
                            Button(action: {
                                loginViewModel.isEmailAlreadyUsed(){ isComplete in
                                    loginViewModel.isAlreadyEmail = isComplete
                                    loginViewModel.showEmailResult = true
                                }
                            }){
                                Text("중복확인")
                            }
                                .padding(6)
                                .foregroundColor(.white)
                                .background(loginViewModel.signUpEmail.count == 0 || loginViewModel.isValidEmail() == false ? .gray : .blue)
                                .cornerRadius(11)
                                .padding(.trailing, 8)
                                .disabled(loginViewModel.signUpEmail.count == 0 || loginViewModel.isValidEmail() == false ? true : false)
                                .alert("확인", isPresented: $loginViewModel.showEmailResult){
                                    Button("확인", role: .cancel){
                                        if loginViewModel.isAlreadyEmail{
                                            loginViewModel.signUpEmail = ""
                                        }
                                    }
                                } message: {
                                    Text(loginViewModel.isAlreadyEmail ? "이미 사용중인 이메일 입니다." : "사용가능한 이메일 입니다.")
                                }
                        }
                        .onChange(of: loginViewModel.signUpEmail){ signUpEmail in
                            loginViewModel.emailCheck = loginViewModel.isValidEmail()
                        }
                        if loginViewModel.signUpEmail.count > 0 {
                            if loginViewModel.isValidEmail() == false{
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
                            TextField("비밀번호를 입력하세요.(8자 이상)", text: $loginViewModel.signUpPassword)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .padding(.trailing, 87)
                                .autocapitalization(.none)
                        }
                        .onChange(of: loginViewModel.signUpPassword){ signUpPassword in
                            loginViewModel.pwdCheck = loginViewModel.isValidPassword()
                        }
                        if loginViewModel.signUpPassword.count > 0 {
                            if loginViewModel.isValidPassword() == false{
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
                            TextField("다시 한 번 입력하세요.", text: $loginViewModel.signUpPasswordCheck)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 15)
                                .padding(.trailing, 90)
                                .autocapitalization(.none)
                        }
                        .onChange(of: loginViewModel.signUpPasswordCheck){ signUpPasswordCheck in
                            loginViewModel.pwdSecondCheck = loginViewModel.isSamePassword()
                        }
                        //비밀번호 확인 -> 1자라도 입력시 비밀번호 일치, 불일치 여부 출력
                        if loginViewModel.signUpPasswordCheck.count > 0 {
                            if loginViewModel.isSamePassword(){
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
                    loginViewModel.writeRegisterUser{ success in
                        if success {
                            loginToSignUpPageActive = false
                        }
                    }
                }
                    .padding(10)
                    .background(!loginViewModel.isAlreadyNickName && !loginViewModel.isAlreadyEmail&&loginViewModel.pwdCheck&&loginViewModel.pwdSecondCheck ? .blue : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.top, 20)
                    .disabled(!loginViewModel.isAlreadyNickName && !loginViewModel.isAlreadyEmail&&loginViewModel.pwdCheck&&loginViewModel.pwdSecondCheck ? false : true)
                Spacer()
            }
            .onAppear{
                loginViewModel.signUpNickname = ""
                loginViewModel.signUpEmail = ""
                loginViewModel.signUpPassword = ""
                loginViewModel.signUpPasswordCheck = ""
            }
        }
        .navigationBarTitle("회원가입")
        .onAppear{
            loginViewModel.isAlreadyEmail = true
            loginViewModel.isAlreadyNickName = true
        }
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(loginViewModel: LoginViewModel(), loginToSignUpPageActive: .constant(true))
    }
}
