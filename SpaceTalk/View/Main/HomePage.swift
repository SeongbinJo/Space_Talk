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
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var loginToMainPageActive: Bool
    
    @State var pushButtonAlert : Bool = false
    
    
    //평소엔 우편함 안 보임.
    @State var postBoxZindex: Double = -1
    
    var body: some View{
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
                            .shadow(color: .black, radius: 4, x: 5, y: 5)
                        Rectangle()
                            .frame(width: geometry.size.width * 0.11, height: geometry.size.height * 0.13)
                            .cornerRadius(10, corners: [.topRight, .topLeft])
                            .foregroundColor(Color(uiColor: UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .shadow(color: .black, radius: 4, x: 5, y: 5)
                    }
                    ZStack{
                        Rectangle()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.63)
                            .cornerRadius(20)
                            .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1)))
                            .overlay(alignment: .bottomTrailing){
                                Text("\(firestoreViewModel.currentUserNickName())의 무전기")
                                    .foregroundColor(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                    .padding(.trailing)
                                    .padding(.bottom)
                            }
                        
                        VStack{
                            TextEditor(text: $firestoreViewModel.firstSendText)
                            //키보드의 '완료'를 누르면 \n을 삭제하고 키보드를 숨겨준다.
                                .onChange(of: firestoreViewModel.firstSendText){ sendText in
                                    if sendText.count > 0{
                                        if sendText.last == "\n"{
                                            firestoreViewModel.firstSendText.removeLast()
                                            hideKeyboard()
                                        }
                                    }
                                }
                            //키보드의 엔터를 '완료'로 바꿔줌.
                                .submitLabel(.done)
                                .scrollContentBackground(.hidden)
                                .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                                .frame(width: geometry.size.width * 0.715, height: geometry.size.height * 0.22)
                                .cornerRadius(15)
                                .padding(.top, -40)
                                .padding(.bottom, 20)
                                .autocapitalization(.none)
                                .overlay(alignment: .topLeading){
                                    Text($firestoreViewModel.firstSendText.wrappedValue.count > 0 ? "" : "100자 이내")
                                        .padding(.top, -33)
                                        .padding(.leading, 7)
                                        .foregroundColor(.black)
                                        .opacity(0.4)
                                        .font(.system(size: geometry.size.width * 0.05))
                                }
                                .overlay(alignment: .bottomTrailing){
                                    Button(action: {
                                        postBoxZindex = 1
                                    }){
                                        //새롭게 받은 메시지가 존재할 경우
                                        //true, false 대체해야함.
                                        Image(systemName: firestoreViewModel.newmessages.count > 0 ? "envelope.fill" : "envelope")
                                            .foregroundColor(firestoreViewModel.newmessages.count > 0 ? Color(UIColor(r: 49, g: 49, b: 49, a: 1.0)) : Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)))
                                            .font(.system(size: geometry.size.width * 0.06))
                                            .padding(.trailing, 10)
                                            .padding(.bottom, 30)
                                    }
                                }
                            Button(action:{
                                firestoreViewModel.randomUser(){complete in
                                    if complete{
                                        print("랜덤뽑기 유저 당첨 : \(firestoreViewModel.randomUserUid)")
                                        firestoreViewModel.sendFirstMessageInHomePage(){ completion in
                                            if completion{
                                                pushButtonAlert = true
                                                firestoreViewModel.firstSendText = ""
                                            }
                                        }
                                    }
                                }
                            }){
                                Circle()
                                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.3)
                                    .foregroundColor(Color(UIColor(r: 79, g: 88, b: 83, a: 1.0)))
                                    .overlay(alignment: .center){
                                        Text("PUSH")
                                            .fontWeight(.bold)
                                            .font(.system(size: geometry.size.width * 0.07))
                                            .foregroundColor(Color(UIColor(r: 211, g: 78, b: 78, a: 1.0)))
                                    }
                            }
                            .contentShape(Circle())
                            .padding(.bottom, -20)
                            .disabled(firestoreViewModel.firstSendText.count == 0 ? true : false)
                            .alert("삐빅!",isPresented: $pushButtonAlert) {
                                Button("확인", role: .cancel) {}
                            } message: {
                                Text("무전을 성공적으로 보냈습니다!")
                            }
                            
                        }//vstack
                    }//텍스트에디터, 푸시버튼 zstack
                }//vstack
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                HomePagePostBox(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, postBoxZindex: $postBoxZindex)
                    .zIndex(postBoxZindex)
                                }//zstack
            }//GeometryReader
            .navigationBarBackButtonHidden(true)
            .onAppear{
            }
        }
    }
    
    struct HomePage_Previews: PreviewProvider {
        static var previews: some View {
            HomePage(loginViewModel: LoginViewModel(), firestoreViewModel: FirestoreViewModel(loginViewModel: LoginViewModel()), loginToMainPageActive: .constant(true))
        }
    }
