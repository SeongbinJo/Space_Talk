//
//  LoginPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/28.
//

import Foundation
import SwiftUI

struct LoginPage: View {

    @EnvironmentObject var loginViewModel : LoginViewModel
    @EnvironmentObject var firestoreViewModel : FirestoreViewModel
    
    @State var goToSignUpPage : Bool = false
    @State var goToMainPage : Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Image("login")
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
                    VStack(alignment: .trailing) {
                        ZStack{
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.007){
                                Text("Email")
                                    .padding(.top, geometry.size.height * 0.02)
                                    .padding(.leading, geometry.size.width * 0.04)
                                TextField("Enter your Email", text: $loginViewModel.email)
                                    .padding(.horizontal, geometry.size.width * 0.04)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                Text("Password")
                                    .padding(.top, geometry.size.height * 0.02)
                                    .padding(.leading, geometry.size.width * 0.04)
                                SecureField("Enter your Password", text: $loginViewModel.password)
                                    .padding(.horizontal, geometry.size.width * 0.04)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                VStack{
                                    HStack{
                                        Spacer()
                                        Button(action:{
                                            loginViewModel.signIn() { complete in
                                                if complete {
                                                    loginViewModel.currentUserInformation { complete in
                                                        if complete {
                                                            firestoreViewModel.currentUser = loginViewModel.currentUser
                                                            self.goToMainPage = true
                                                        }
                                                    }
                                                }else {
                                                    print("로그인 실패!")
                                                }
                                            }
                                        }){
                                            Text("로그인")
                                                .padding(10)
                                                .background(.white)
                                                .cornerRadius(10)
                                                .foregroundColor(.black)
                                        }
                                        .padding()
                                        NavigationLink(destination: MainPage(goToMainPage: $goToMainPage), isActive: $goToMainPage, label: {EmptyView()})
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.3)
                            .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                            .cornerRadius(20)
                        }//zstack
                        .shadow(color: .black, radius: 10, x: 5, y: 5)
                            Button(action: {
                                goToSignUpPage = true
                            }) {
                                Text("회원가입")
                                    .padding(.trailing, -5)
                                    .foregroundColor(Color(UIColor(r: 240, g: 240, b: 240, a: 1)))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: geometry.size.width * 0.03))
                                    .foregroundColor(Color(UIColor(r: 240, g: 240, b: 240, a: 1)))
                            }
                            .padding(.top, geometry.size.height * 0.01)
                            NavigationLink(destination: SignUpPage(goToSignUpPage: $goToSignUpPage), isActive: $goToSignUpPage, label: {EmptyView()})

                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                .position(x: geometry.frame(in: .local).midX, y: geometry.size.height * 0.55)
                }
            }//geometryreader
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            loginViewModel.email = ""
            loginViewModel.password = ""
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
