//
//  LoginSuccess.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct MainPage: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    //LoginPage의 네비게이션 링크
    @Binding var loginToMainPageActive: Bool
    
    @State var str: String = "home"
    
    var body: some View{
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    //버튼을 클릭하여 str값이 변경되면, 하단의 버튼은 남고 화면만 바뀐다. zstack 덕분!
                    loginViewModel.changeTabView(tabindex: str, loginToMainPageActive: $loginToMainPageActive)
                    HStack(spacing: 0){
                        Button(action:{
                            print("홈 버튼 클릭됨")
                            withAnimation{
                                str = "home"
                            }
                        }){
                            Image(systemName: str == "home" ? "house.fill" : "house")
                                .foregroundColor(.black)
                                .font(.system(size: 25))
                                .scaleEffect(str == "home" ? 1.2 : 0.9)
                        }
                        .frame(width: geometry.size.width / 3)
                        
                        Button(action:{
                            print("채팅 리스트 버튼 클릭됨")
                            withAnimation{
                                str = "chatList"
                            }
                        }){
                            Image(systemName: str == "chatList" ? "bubble.left.fill" : "bubble.left")
                                .foregroundColor(.black)
                                .font(.system(size: 25))
                                .scaleEffect(str == "chatList" ? 1.2 : 0.9)
                        }
                        .frame(width: geometry.size.width / 3)
                        
                        Button(action:{
                            print("설정 버튼 클릭됨")
                            withAnimation{
                                str = "setting"
                            }
                        }){
                            Image(systemName: str == "setting" ? "ellipsis.circle.fill" : "ellipsis.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 25))
                                .scaleEffect(str == "setting" ? 1.2 : 0.9)
                        }
                        .frame(width: geometry.size.width / 3)
                    }//hstack
                    .frame(height: 70)
                    .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    .padding(.bottom, 9)
                    .overlay(alignment: .top){
                        Rectangle()
                            .frame(height: 0.7)
                            .foregroundColor(Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)))
                    }
                    .position(CGPoint(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).maxY))
                }//ztack
            }//geometry
        }
        .navigationBarBackButtonHidden(true)
    }
    
    struct LoginSuccess_Previews: PreviewProvider {
        static var previews: some View {
            MainPage(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
        }
    }
    
    
}
