//
//  HomePage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/03.
//

import Foundation
import SwiftUI

struct HomePage: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    @State var sendTextField: String = ""
    
    var body: some View{
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    Color.gray.ignoresSafeArea()
                    VStack(spacing: 0){
                        HStack(alignment: .bottom){
                            Rectangle()
                                .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.04)
                                .cornerRadius(10, corners: [.topRight, .topLeft])
                                .padding(.trailing, geometry.size.width * 0.35)
                                .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            Rectangle()
                                .frame(width: geometry.size.width * 0.11, height: geometry.size.height * 0.13)
                                .cornerRadius(10, corners: [.topRight, .topLeft])
                                .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                        }
                        ZStack{
                            Rectangle()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.63)
                                .cornerRadius(20)
                                .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            VStack{
                                TextEditor(text: $sendTextField)
                                    .scrollContentBackground(.hidden)
                                    .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                    .frame(width: geometry.size.width * 0.715, height: geometry.size.height * 0.22)
                                    .cornerRadius(15)
                                    .padding(.top, -40)
                                    .padding(.bottom, 20)
                                    .autocapitalization(.none)
                                    .overlay(alignment: .topLeading){
                                        Text(sendTextField.isEmpty ? "100자 이내" : "")
                                            .padding(.top, -33)
                                            .padding(.leading, 7)
                                            .foregroundColor(.black)
                                            .opacity(0.4)
                                    }
                                    .overlay(alignment: .top){
                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.66, height: 1)
                                            .foregroundColor(.black)
                                            .opacity(sendTextField.isEmpty ? 0.4 : 0.0)
                                    }
                                Button(action:{}){
                                    Text("PUSH")
                                        .fontWeight(.bold)
                                        .font(.system(size: 25))
                                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.3)
                                        .foregroundColor(Color(UIColor(r: 211, g: 78, b: 78, a: 1.0)))
                                }
                                .background(Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)))
                                .clipShape(Circle())
                                .padding(.bottom, -20)
                            }
                        }
                        Button(action:{
                            loginViewModel.logoutUser()
                            print("로그아웃!!")
                            loginToMainPageActive = false
                        }){
                            Text("로그아웃")
                                .padding()
                                .foregroundColor(.black)
                        }
                    }//vstack
                }//zstack
            }
        }//navigationview
        .navigationBarBackButtonHidden(true)
        .onAppear{
            print("open home Page")
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(loginViewModel: LoginViewModel(), loginToMainPageActive: .constant(true))
    }
}
