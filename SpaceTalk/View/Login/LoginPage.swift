//
//  LoginPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/28.
//

import Foundation
import SwiftUI

struct LoginPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    @State var loginToSignUpPageActive: Bool = false
    @State var loginToMainPageActive: Bool = false
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    @State var isCheckboxOn: Bool = false
    
    var body: some View {
        NavigationView{
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
                        SecureField("Enter your Password", text: $userPassword)
                            .padding(.horizontal, 17.0)
                            .padding(.bottom, 13)
                            .textFieldStyle(.roundedBorder)
                        VStack(alignment: .trailing){
                            HStack{
                                Spacer()
                                Button("로그인"){
                                    loginViewModel.loginUser(email: userEmail, password: userPassword){ success in
                                        if success {
                                            loginToMainPageActive = true
                                        }
                                    }
                                }
                                .padding(10)
                                .background(.white)
                                .cornerRadius(15)
                                .foregroundColor(.black)
                                NavigationLink(destination: LoginSuccess(loginViewModel: LoginViewModel(), loginToMainPageActive: $loginToMainPageActive), isActive: $loginToMainPageActive, label: {EmptyView()})
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
                Button(action: {
                    loginToSignUpPageActive = true
                }, label: {
                    Text("회원가입")
                        
                })
                .foregroundColor(.black)
                .padding(-15)
                .padding(.trailing, 40)
                NavigationLink(destination: SignUpPage(loginViewModel: LoginViewModel(), loginToSignUpPageActive: $loginToSignUpPageActive), isActive: $loginToSignUpPageActive, label: {EmptyView()})
                //쓸모없는 부분. 나중에 지워야함!!
                Text("로그인 여부(User uid) : \(loginViewModel.currentUser?.uid ?? "비 로그인")")
                    .padding()
                Spacer()
            }//vstack
            .onAppear{
                //로그인 화면은 '로그아웃' 이던 '계정탈퇴' 이던 로그인 여부는 무조건 false이기 때문
                loginViewModel.currentUser = nil
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(loginViewModel: LoginViewModel())
    }
}

