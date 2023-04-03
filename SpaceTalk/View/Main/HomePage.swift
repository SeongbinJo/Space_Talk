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
            VStack{
                HStack(alignment: .bottom){
                    Rectangle()
                        .frame(width: 45, height: 30)
                        .cornerRadius(10, corners: [.topRight, .topLeft])
                        .padding(.trailing, 140)
                        .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                    Rectangle()
                        .frame(width: 45, height: 90)
                        .cornerRadius(10, corners: [.topRight, .topLeft])
                        .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                }
                ZStack{
                    Rectangle()
                        .frame(width: 300, height: 450)
                        .cornerRadius(20)
                        .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                    VStack{
                        TextEditor(text: $sendTextField)
                            .frame(width: 250, height: 150)
                            .cornerRadius(20)
                            .padding(.top, -40)
                            .padding(.bottom, 20)
                            .autocapitalization(.none)
                            .overlay(Text(sendTextField.isEmpty ? "100자 이내" : "")
                                .padding(.top, -33)
                                .padding(.leading, 7)
                                .foregroundColor(.gray)
                                , alignment: .topLeading)
                        Button(action:{}){
                            Text("PUSH")
                                .fontWeight(.bold)
                                .font(.system(size: 25))
                                .frame(width: 200, height: 200)
                                .foregroundColor(.black)
                        }
                        .background(.white)
                        .clipShape(Circle())
                        .padding(.bottom, -20)
                        
                    }
                }
                .padding(.top, -10)
                Button("로그아웃"){
                    loginViewModel.logoutUser()
                    loginToMainPageActive = false
                }
                .foregroundColor(.black)
            }//vstack
            
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
