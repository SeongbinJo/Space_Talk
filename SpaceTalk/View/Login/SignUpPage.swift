//
//  SignUpPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/21.
//

import Foundation
import SwiftUI

struct SignUpPage: View {
    
    @EnvironmentObject var loginViewModel : LoginViewModel
    
    @Binding var goToSignUpPage : Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Image("chatlist")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                        .clipped()
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    VStack {
                        Text("Background Author - Alvish Baldha")
                            .font(.system(size: geometry.size.width * 0.02))
                            .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                        Text("Original Link - https://www.figma.com/community/file/786982732117165587/space")
                            .font(.system(size: geometry.size.width * 0.02))
                            .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                            .accentColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                        Text("Licensed under CC BY 4.0")
                            .font(.system(size: geometry.size.width * 0.02))
                            .foregroundColor(Color(uiColor: UIColor(r: 187, g: 187, b: 187, a: 1)))
                    }
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).height * 0.97)
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                        .foregroundColor(Color.gray.opacity(0.6))
                    VStack {
                        VStack(alignment: .leading) {
                            Text("닉네임")
                                .foregroundColor(.white)
                                .padding(.leading, geometry.size.width * 0.02)
                                .padding(.top, geometry.size.width * 0.02)
                            HStack {
                                TextField("사용할 닉네임을 입력하세요.", text: $loginViewModel.signUpNickname)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.leading, geometry.size.width * 0.02)
                                    .autocapitalization(.none)
                                Button(action: {
                                    loginViewModel.existNickname() { complete in
                                        //팝업창 나오는 코드
                                    }
                                }) {
                                    Text("중복확인")
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(loginViewModel.signUpNickname.count > 0 && loginViewModel.isValidNickname() ? .blue : .gray)
                                        .cornerRadius(5, corners: .allCorners)
                                        .padding(.trailing, geometry.size.width * 0.02)
                                }
                                .disabled(loginViewModel.signUpNickname.count > 0 && loginViewModel.isValidNickname() ? false : true)
                            }
    //                        .onChange(of: loginViewModel.signUpNickname) { signUPNickname in
    //                            loginViewModel.nickNameCheck = loginViewModel.isValidNickname()
    //                        }
                            if loginViewModel.signUpNickname.count > 0 {
                                if loginViewModel.isValidNickname() == false{
                                    Text("공백과 특수문자를 제외한 1-10 글자를 입력해주세요.")
                                        .padding(.leading, 15)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                        .padding(.bottom, 1)
                                }
                            }
                            HStack {
                                Text("이메일")
                                    .padding(.leading, geometry.size.width * 0.02)
                                    .foregroundColor(.white)
                                Text("(메일 인증을 위해 사용중인 이메일을 입력해주세요.)")
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            HStack {
                                TextField("사용할 이메일을 입력하세요.", text: $loginViewModel.signUpEmail)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.leading, geometry.size.width * 0.02)
                                    .autocapitalization(.none)
                                Button(action: {
                                    loginViewModel.existEmail() { complete in
                                        //팝업창 나오는 코드
                                    }
                                }) {
                                    Text("중복확인")
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(loginViewModel.signUpEmail.count > 0 && loginViewModel.isValidEmail() ? .blue : .gray)
                                        .cornerRadius(5, corners: .allCorners)
                                        .padding(.trailing, geometry.size.width * 0.02)
                                }
                                .disabled(loginViewModel.signUpEmail.count > 0 && loginViewModel.isValidEmail() ? false : true)
                            }
    //                        .onChange(of: loginViewModel.signUpEmail) { signUpEmail in
    //                            loginViewModel.emailCheck = loginViewModel.isValidEmail()
    //                        }
                            if loginViewModel.signUpEmail.count > 0 {
                                if loginViewModel.isValidEmail() == false{
                                    Text("이메일 형식이 맞지 않습니다.")
                                        .padding(.leading, 15)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                        .padding(.bottom, 1)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("비밀번호")
                                    .foregroundColor(.white)
                                    .padding(.leading, geometry.size.width * 0.02)
                                TextField("사용할 비밀번호을 입력하세요.", text: $loginViewModel.signUpPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.leading, geometry.size.width * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.23)
                                    .autocapitalization(.none)
                                    .onChange(of: loginViewModel.signUpPassword) { signUpPassword in
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
                            VStack(alignment: .leading) {
                                Text("비밀번호 확인")
                                    .foregroundColor(.white)
                                    .padding(.leading, geometry.size.width * 0.02)
                                TextField("비밀번호를 다시 입력해주세요.", text: $loginViewModel.signUpPasswordCheck)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.leading, geometry.size.width * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.23)
                                    .autocapitalization(.none)
                                if loginViewModel.signUpPasswordCheck.count > 0 {
                                    if loginViewModel.signUpPasswordCheck == loginViewModel.signUpPassword {
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
                        Button(action: {
                            loginViewModel.signUp() { complete in
                                if complete {
                                    self.goToSignUpPage = false
                                }
                            }
                        }) {
                            Text("가입하기")
                                .padding(5)
                                .background(Color(UIColor(r: 254, g: 247, b: 189, a: 1)))
                                .cornerRadius(7, corners: .allCorners)
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                        }
    //                    .disabled()
                        Spacer()
                    }
                }
            }//geometry
        }
        .navigationTitle("회원가입")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.goToSignUpPage = false
        }){
            HStack{
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.white)
                Text("뒤로가기")
                    .foregroundColor(Color.white)
            }
        })
        .onAppear {
            loginViewModel.signUpEmail = ""
            loginViewModel.signUpNickname = ""
            loginViewModel.signUpPassword = ""
            loginViewModel.signUpPasswordCheck = ""
        }
    }
    
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(goToSignUpPage: .constant(true))
    }
}
