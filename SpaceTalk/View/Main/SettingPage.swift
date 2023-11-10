//
//  SettingPage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/23.
//

import Foundation
import SwiftUI

struct SettingPage: View {
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var goToMainPage: Bool
    
    @State var SignOutAlert: Bool = false
    @State var deleteUserAlert: Bool = false
    @State var blockUserPageZindex: CGFloat = -1
    
    var body: some View {
//        Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)).ignoresSafeArea()
        GeometryReader{ geometry in
            ZStack{
                Image("home")
                    .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
                                .clipped()
                                .rotationEffect(.degrees(180))
                                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                VStack(spacing: 0) {
                    HStack(alignment: .bottom){
                        Rectangle()
                            .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.03)
                            .cornerRadius(10, corners: [.topRight, .topLeft])
                            .padding(.trailing, geometry.size.width * 0.3)
                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .shadow(color: .black, radius: 10, x: 5, y: 5)
                        Rectangle()
                            .frame(width: geometry.size.width * 0.11, height: geometry.size.height * 0.11)
                            .cornerRadius(10, corners: [.topRight, .topLeft])
                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .shadow(color: .black, radius: 10, x: 5, y: 5)
                    }
                    Rectangle()
                        .frame(width: geometry.size.width * 0.73, height: geometry.size.height * 0.59)
                        .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                        .cornerRadius(20, corners: .allCorners)
                        .shadow(color: .black, radius: 10, x: 5, y: 5)
//                        .padding()
//                        .padding(.bottom, geometry.size.height * 0.07)
                        .overlay(
                                VStack(alignment: .leading){
                                    //유저 프로필
                                    Rectangle()
                                        .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                        .cornerRadius(15, corners: .allCorners)
                                        .frame(width: geometry.size.width * 0.65, height: geometry.size.height * 0.21)
                                        .overlay(
                                            VStack(alignment: .leading){
                                                Text("\(loginViewModel.currentNickname)'s 무전기")
                                                    .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                    .font(.system(size: geometry.size.width * 0.06))
                                                    .fontWeight(.bold)
                                                Spacer()
                                                Spacer()
                                                Spacer()
                                                Text("이메일 : \(loginViewModel.currentEmail)")
                                                    .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                    .font(.system(size: geometry.size.width * 0.047))
                                                Spacer()
                                                Text("닉네임 : \(loginViewModel.currentNickname)")
                                                    .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                    .font(.system(size: geometry.size.width * 0.047))
                                                Spacer()
                                                HStack{
                                                    
    //                                                Spacer()
    //                                                Rectangle()
    //                                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.width * 0.08)
    //                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
    //                                                    .cornerRadius(7, corners: .allCorners)
    //                                                    .overlay(
    //                                                        Button(action: {
    //
    //                                                        }){
    //                                                            Text("변경")
    //                                                                .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
    //                                                                .font(.system(size: geometry.size.width * 0.047))
    //                                                        }
    //                                                    )
                                                }
                                            }
                                                .padding(geometry.size.height * 0.02),
                                            alignment: .leading
                                        )
                                    //구분선
                                    Rectangle()
                                        .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                        .frame(width: geometry.size.width * 0.65, height: 1)
                                        .padding(.vertical, geometry.size.height * 0.01)
                                    //설정 기능 버튼들
                                    HStack(spacing: geometry.size.width * 0.06){
        //                                Spacer()
        //                                VStack(spacing: 2){
        //                                    Button(action: {
        //                                    }){
        //                                        Rectangle()
        //                                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
        //                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
        //                                            .cornerRadius(15, corners: .allCorners)
        //                                            .overlay(
        //                                                Image(systemName: "lock")
        //                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
        //                                                    .font(.system(size: geometry.size.width * 0.07))
        //                                            )
        //                                    }
        //                                    Text("잠금설정")
        //                                        .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
        //                                        .font(.system(size: geometry.size.width * 0.038))
        //                                }
                                        VStack(spacing: 2){
                                            Button(action: {
                                                firestoreViewModel.getBlockUserList() { complete in
                                                    if complete {
                                                        self.blockUserPageZindex = 1
                                                    }
                                                }
                                            }){
                                                Rectangle()
                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                    .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                    .cornerRadius(15, corners: .allCorners)
                                                    .overlay(
                                                        Image(systemName: "person.2.slash")
                                                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                            .font(.system(size: geometry.size.width * 0.07))
                                                    )
                                            }
                                            Text("차단목록")
                                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                .font(.system(size: geometry.size.width * 0.038))
                                        }
                                        VStack(spacing: 2){
                                            Button(action: {
                                                self.SignOutAlert = true
                                            }){
                                                Rectangle()
                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                    .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                    .cornerRadius(15, corners: .allCorners)
                                                    .overlay(
                                                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                                                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                            .font(.system(size: geometry.size.width * 0.07))
                                                    )
                                            }
                                            .alert("로그아웃", isPresented: $SignOutAlert) {
                                                Button("취소", role: .cancel) {}
                                                Button("로그아웃") {
                                                    loginViewModel.signOut()
                                                    self.goToMainPage = false
                                                }
                                            } message: {
                                                Text("정말로 로그아웃 하시겠습니까?")
                                            }
                                            .foregroundColor(.black)
                                            Text("로그아웃")
                                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                .font(.system(size: geometry.size.width * 0.038))
                                        }
                                        VStack(spacing: 2){
                                            Button(action: {
                                                deleteUserAlert = true
                                            }){
                                                Rectangle()
                                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                    .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                    .cornerRadius(15, corners: .allCorners)
                                                    .overlay(
                                                        ZStack{
                                                            Image(systemName: "person")
                                                                .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                                                                .font(.system(size: geometry.size.width * 0.08))
                                                            Image(systemName: "multiply")
                                                                .foregroundColor(Color.red)
                                                                .font(.system(size: geometry.size.width * 0.12))
                                                        }
                                                    )
                                            }
                                            .alert("주의!", isPresented: $deleteUserAlert) {
                                                Button("취소", role: .cancel) {}
                                                Button(role: .destructive, action: {
                                                    loginViewModel.deleteUser()
                                                    self.goToMainPage = false
                                                }) {
                                                    Text("탈퇴")
                                                }
                                            } message: {
                                                Text("정말로 계정탈퇴 하시겠습니까?")
                                            }
                                            .foregroundColor(.red)
                                            Text("계정탈퇴")
                                                .foregroundColor(Color.red)
                                                .font(.system(size: geometry.size.width * 0.038))
                                        }
        //                                Spacer()
                                    }
                                }
                                    .padding(.top, geometry.size.height * 0.02)
//                                    .frame(width: geometry.size.width * 0.65, height: geometry.size.height * 0.21)
                                ,
                                alignment: .top
                        )
                        .padding(.bottom, geometry.size.width * 0.15)
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
                }
                .position(x: geometry.frame(in: .local).midX, y: geometry.size.height * 0.45)
                
                VStack {
                    List {
                        ForEach(firestoreViewModel.blockedUserList, id: \.id) { blockUser in
//                            Text(blockUser.blockUserNickName)
                            Rectangle()
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.06)
                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                .cornerRadius(10, corners: .allCorners)
                                .overlay(alignment: .leading) {
                                    Text(blockUser.blockUserNickName)
                                        .padding(.horizontal, geometry.size.width * 0.02)
                                }
                        }
                        .onDelete(perform: firestoreViewModel.removeList)
                        .listRowBackground(Color.clear)
                    }
                    .onAppear {
                        firestoreViewModel.blockedUserList.removeAll()
                    }
                        .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.5)
                        .scrollContentBackground(.hidden)
                        .background(Color(UIColor(r: 94, g: 94, b: 94, a: 0.7)))
                        .cornerRadius(20, corners: .allCorners)
                        .shadow(color: .black, radius: 7, x: 3, y: 3)
                    Button(action: {
                        firestoreViewModel.blockedUserList.removeAll()
                        print("firestoreviewmodel.blockeduserlist = \(firestoreViewModel.blockedUserList)")
                        self.blockUserPageZindex = -1
                    }) {
                        Circle()
                            .frame(width: geometry.size.width * 0.13)
                            .foregroundColor(Color(UIColor(r: 94, g: 94, b: 94, a: 0.7)))
                            .shadow(color: .black, radius: 7, x: 3, y: 3)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: geometry.size.width * 0.05))
                                    .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            )
                    }
                }
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .zIndex(self.blockUserPageZindex)
            }
        }
    }
}
