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
            ZStack{
//                Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)).ignoresSafeArea()
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
                                .autocapitalization(.none)
                            Text("Password")
                                .padding(.top, 10)
                                .padding(.leading, 17)
                            SecureField("Enter your Password", text: $userPassword)
                                .padding(.horizontal, 17.0)
                                .padding(.bottom, 13)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                            VStack{
                                HStack{
                                    Spacer()
                                    Button(action:{
                                        loginViewModel.loginUser(email: userEmail, password: userPassword){ success in
                                            if success {
                                                loginToMainPageActive = true
                                            }
                                        }
                                    }){
                                        Text("로그인")
                                            .padding(10)
                                            .background(.white)
                                            .cornerRadius(17)
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    NavigationLink(destination: MainPage(loginViewModel: loginViewModel, firestoreViewModel: FirestoreViewModel(loginViewModel: loginViewModel), loginToMainPageActive: $loginToMainPageActive),isActive: $loginToMainPageActive, label: {EmptyView()})
                                    Spacer()
                                }
                            }
                        }
                        .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                        .cornerRadius(20)
                    }//zstack
                    .padding()
                    VStack(alignment: .trailing){
                        HStack{
                            Text("회원이 아니라면?")
                            Button(action: {
                                loginToSignUpPageActive = true
                            }, label: {
                                HStack(spacing: 3){
                                    Text("회원가입")
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 13))
                                }
                                .padding()
                            })
                            .padding(-15)
                            .padding(.trailing, 40)
                            NavigationLink(destination: SignUpPage(loginViewModel: loginViewModel, loginToSignUpPageActive: $loginToSignUpPageActive), isActive: $loginToSignUpPageActive, label: {EmptyView()})
                        }
                        //쓸모없는 부분. 나중에 지워야함!!
                        Text("로그인 여부(uid) : \(loginViewModel.currentUser?.uid ?? "비 로그인")")
                            .padding()
                    }
                    Spacer()
                }//vstack
                .onAppear{
                    //로그인 화면은 '로그아웃' 이던 '계정탈퇴' 이던 로그인 여부는 무조건 false이기 때문
    //                loginViewModel.currentUser = nil
                    userEmail = ""
                    userPassword = ""
                }
            }
            
        }//navigationview
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(loginViewModel: LoginViewModel())
    }
}
