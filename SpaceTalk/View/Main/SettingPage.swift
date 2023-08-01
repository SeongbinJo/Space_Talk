//
//  SettingPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/06.
//

import Foundation
import SwiftUI

struct SettingPage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    @State var showLogoutAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    //Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1))  -> 무전기 몸통 색
    //Color(UIColor(r: 132, g: 141, b: 136, a: 1.0))  -> 무전기 화면 색
    var body: some View{
        Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)).ignoresSafeArea()
        GeometryReader{ geometry in
            ZStack{
                Rectangle()
                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    .cornerRadius(20, corners: .allCorners)
                    .padding()
                    .padding(.bottom, geometry.size.height * 0.07)
                    .overlay(
                        VStack{
                            HStack{
                                Text("설정")
                                    .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                    .font(.system(size: geometry.size.width * 0.06))
                            }
                            HStack(spacing: geometry.size.width * 0.1){
                                VStack(spacing: 2){
                                    Button(action: {
                                        showLogoutAlert = true
                                    }){
                                        Rectangle()
                                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                            .cornerRadius(15, corners: .allCorners)
                                            .overlay(
                                                Image(systemName: "rectangle.portrait.and.arrow.forward")
                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                    .font(.system(size: geometry.size.width * 0.07))
                                            )
                                    }
                                    .alert("로그아웃", isPresented: $showLogoutAlert) {
                                        Button("취소", role: .cancel) {}
                                        Button("로그아웃") {
                                            loginViewModel.logoutUser()
                                            loginToMainPageActive = false
                                            print(loginToMainPageActive)
                                        }
                                    } message: {
                                        Text("정말로 로그아웃 하시겠습니까?")
                                    }
                                    .foregroundColor(.black)
                                    Text("로그아웃")
                                        .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                        .font(.system(size: geometry.size.width * 0.038))
                                }
                                VStack(spacing: 2){
                                    Button(action: {
                                        showDeleteAlert = true
                                    }){
                                        Rectangle()
                                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                            .cornerRadius(15, corners: .allCorners)
                                            .overlay(
                                                ZStack{
                                                    Image(systemName: "person")
                                                        .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                        .font(.system(size: geometry.size.width * 0.08))
                                                    Image(systemName: "multiply")
                                                        .foregroundColor(Color.red)
                                                        .font(.system(size: geometry.size.width * 0.12))
                                                }
                                            )
                                    }
                                    .alert("주의!", isPresented: $showDeleteAlert) {
                                        Button("취소", role: .cancel) {}
                                        Button(role: .destructive, action: {
                                            loginViewModel.deleteUser()
                                            loginToMainPageActive = false
                                        }) {
                                            Text("탈퇴하기")
                                        }
                                    } message: {
                                        Text("정말로 계정탈퇴 하시겠습니까?")
                                    }
                                    .foregroundColor(.red)
                                    Text("계정탈퇴")
                                        .foregroundColor(Color.red)
                                        .font(.system(size: geometry.size.width * 0.038))
                                }
                                Spacer()
                            }
                        }
                            .padding(geometry.size.height * 0.04)
                        ,
                        alignment: .topLeading
                    )
            }
        }
//            Color.gray.ignoresSafeArea()
//            List{
//                Button(action: {
//                    showLogoutAlert = true
//                }){
//                    Text("로그아웃")
//                }
//                .alert("로그아웃", isPresented: $showLogoutAlert) {
//                    Button("취소", role: .cancel) {}
//                    Button("로그아웃") {
//                        loginViewModel.logoutUser()
//                        loginToMainPageActive = false
//                        print(loginToMainPageActive)
//                    }
//                } message: {
//                    Text("정말로 로그아웃 하시겠습니까?")
//                }
//                .foregroundColor(.black)
//                Button(action: {
//                    showDeleteAlert = true
//                }){
//                    Text("계정탈퇴")
//                }
//                .alert("주의!", isPresented: $showDeleteAlert) {
//                    Button("취소", role: .cancel) {}
//                    Button(action: {
//                        loginViewModel.deleteUser()
//                        loginToMainPageActive = false
//                    }) {
//                        Text("탈퇴하기")
//                    }
//                } message: {
//                    Text("정말로 계정탈퇴 하시겠습니까?")
//                }
//                .foregroundColor(.red)
//            }
    }//body
    
    
    struct SettingPage_Previews: PreviewProvider {
        static var previews: some View {
            SettingPage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), loginToMainPageActive: .constant(true))
        }
    }
}
