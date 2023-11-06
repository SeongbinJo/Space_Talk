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
        Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)).ignoresSafeArea()
        GeometryReader{ geometry in
            ZStack{
                Rectangle()
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.85)
                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    .cornerRadius(20, corners: .allCorners)
                    .padding()
                    .padding(.bottom, geometry.size.height * 0.07)
                    .overlay(
                            VStack(alignment: .leading){
                                //유저 프로필
                                Rectangle()
                                    .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                    .cornerRadius(20, corners: .allCorners)
                                    .frame(height: geometry.size.height * 0.2)
                                    .overlay(
                                        VStack(alignment: .leading){
                                            Text("\(loginViewModel.currentNickname)'s 무전기")
                                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                .font(.system(size: geometry.size.width * 0.06))
                                                .fontWeight(.bold)
                                            Spacer()
                                            Spacer()
                                            Spacer()
                                            Text("이메일 : \(loginViewModel.currentEmail)")
                                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                .font(.system(size: geometry.size.width * 0.047))
                                            Spacer()
                                            Text("닉네임 : \(loginViewModel.currentNickname)")
                                                .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
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
                                    .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                    .frame(height: 1)
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
                                                .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                                .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                .cornerRadius(15, corners: .allCorners)
                                                .overlay(
                                                    Image(systemName: "person.2.slash")
                                                        .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                                        .font(.system(size: geometry.size.width * 0.07))
                                                )
                                        }
                                        Text("차단목록")
                                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                            .font(.system(size: geometry.size.width * 0.038))
                                    }
                                    VStack(spacing: 2){
                                        Button(action: {
                                            self.SignOutAlert = true
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
                                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)))
                                            .font(.system(size: geometry.size.width * 0.038))
                                    }
                                    VStack(spacing: 2){
                                        Button(action: {
                                            deleteUserAlert = true
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
                                .padding(geometry.size.height * 0.04)
                            ,
                            alignment: .top
                        
                    )
                    .position(x: geometry.frame(in: .local).midX, y: geometry.size.height * 0.48)
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
                        .background(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 0.7)))
                        .cornerRadius(20, corners: .allCorners)
                        .overlay (
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)), lineWidth: 1)
                        )
                        .shadow(color: .black, radius: 7, x: 3, y: 3)
                    Button(action: {
                        firestoreViewModel.blockedUserList.removeAll()
                        print("firestoreviewmodel.blockeduserlist = \(firestoreViewModel.blockedUserList)")
                        self.blockUserPageZindex = -1
                    }) {
                        Circle()
                            .frame(width: geometry.size.width * 0.13)
                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .shadow(color: .black, radius: 7, x: 3, y: 3)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: geometry.size.width * 0.05))
                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                            )
                    }
                }
                .position(x: geometry.frame(in: .local).midX, y: geometry.size.height * 0.565)
                .zIndex(self.blockUserPageZindex)
            }
        }
    }
}
