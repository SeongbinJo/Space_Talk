//
//  HomePage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/22.
//

import Foundation
import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @State var pushButtonAlert: Bool = false
    @State var pushFailedAlert: Bool = false
    
    @State var postBoxZIndex: Double = -2
    
    @State var pushButtonAvailable: Bool = false
    
    var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        Image("home")
                            .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                        .clipped()
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
                            ZStack{
                                VStack{
                                    TextEditor(text: $firestoreViewModel.firstMessageText)
                                        .onChange(of: firestoreViewModel.firstMessageText) { sendText in
                                            if sendText.count > 0 {
                                                print(firestoreViewModel.currentUser)
                                                if sendText.last == "\n" {
                                                    firestoreViewModel.firstMessageText.removeLast()
                                                    hideKeyboard()
                                                }
                                            }
                                        }
                                    //키보드의 엔터를 '완료'로 바꿔줌.
                                    .submitLabel(.done)
                                    .scrollContentBackground(.hidden)
                                    .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                    .frame(width: geometry.size.width * 0.65, height: geometry.size.height * 0.21)
                                    .cornerRadius(15)
                                    .padding(.top, -geometry.size.height * 0.07)
                                    .padding(.bottom, geometry.size.height * 0.01)
                                    .autocapitalization(.none)
                                    .overlay(alignment: .topLeading){
                                        Text($firestoreViewModel.firstMessageText.wrappedValue.count > 0 ? "" : "메시지를 입력하세요.")
                                            .padding(.top, -geometry.size.height * 0.06)
                                            .padding(.leading, 7)
                                            .foregroundColor(.black)
                                            .opacity(0.4)
                                            .font(.system(size: geometry.size.width * 0.05))
                                    }
                                    .overlay(alignment: .bottomTrailing){
                                        Button(action: {
                                            postBoxZIndex = 1
                                        }){
                                            //새롭게 받은 메시지가 존재할 경우
                                            //true, false 대체해야함.
                                            Image(systemName: firestoreViewModel.firstMessages.count > 0 ? "envelope.fill" : "envelope")
                                                .foregroundColor(firestoreViewModel.firstMessages.count > 0 ? Color.white : Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)))
                                                .font(.system(size: geometry.size.width * 0.06))
                                                .padding(.trailing, geometry.size.width * 0.015)
                                                .padding(.bottom, geometry.size.width * 0.025)
                                        }
                                    }
                                    Button(action:{
                                        print("PUSH버튼을 누릅니다.")
                                        self.pushButtonAvailable = true
                                        firestoreViewModel.sendFirstMessageInHomePage() { complete in
                                            if complete {
                                                print("PUSH버튼의 실행이 완료되었습니다.")
                                                self.pushButtonAlert = true
                                                self.pushButtonAvailable = false
                                            }else {
                                                print("PUSH 실패!")
                                                self.pushFailedAlert = true
                                                self.pushButtonAvailable = false
                                            }
                                        }
                                    }){
                                        Circle()
                                            .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.25)
                                            .foregroundColor(firestoreViewModel.firstMessageText.count > 0 ? Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)) : Color(UIColor(r: 211, g: 78, b: 78, a: 0.5)))
                                            .shadow(color: .black, radius: 10, x: firestoreViewModel.firstMessageText.count > 0 ? 5 : 0, y: firestoreViewModel.firstMessageText.count > 0 ? 5 : 0)
                                            .overlay(alignment: .center){
                                                Text("PUSH")
                                                    .fontWeight(.bold)
                                                    .font(.system(size: geometry.size.width * 0.07))
                                                    .foregroundColor(Color(UIColor(r: 211, g: 78, b: 78, a: 1.0)))
                                            }
                                            .alert("삐빅!",isPresented: $pushButtonAlert) {
                                                Button("확인", role: .cancel) {
                                                    firestoreViewModel.firstMessageText = ""
                                                }
                                            } message: {
                                                Text("무전을 성공적으로 보냈습니다!")
                                            }
                                            .alert("웨앵웨앵!", isPresented: $pushFailedAlert) {
                                                Button("확인", role: .cancel) {
                                                    firestoreViewModel.firstMessageText = ""
                                                }
                                            } message: {
                                                Text("무전에 실패하였습니다. 다시 시도해주세요!")
                                            }
                                            
                                    }
                                    .padding(.top, geometry.size.width * 0.04)
                                    .disabled(firestoreViewModel.firstMessageText.count > 0 && self.pushButtonAvailable == false ? false : true)
                                    .contentShape(Circle())
                                    .padding(.bottom, -20)}//vstack
                            }//텍스트에디터, 푸시버튼 zstack
                            .frame(width: geometry.size.width * 0.73, height: geometry.size.height * 0.59)
                            .background(Color(UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .cornerRadius(20)
                            .overlay(alignment: .bottomTrailing){
                                Text("\(loginViewModel.currentNickname)의 무전기")
                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                    .padding()
                            }
                            .shadow(color: .black, radius: 10, x: 5, y: 5)
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
                        .zIndex(2)
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.45)
                    PostBox(postBoxZIndex: $postBoxZIndex)
                        .shadow(color: .black, radius: 7, x: 3, y: 3)
                        .zIndex(postBoxZIndex)
                }
                .ignoresSafeArea(.keyboard)
    }
    
}

//struct HomePage_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePage()
//    }
//}
