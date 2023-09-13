//
//  MessageTextBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/24.
//

import Foundation
import SwiftUI

struct MessageTextBox: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var selectChatListData: [String : Any]
    
    var body: some View {
        GeometryReader{ geomtry in
            VStack{
                    HStack{
                        Button(action: {}){
                            Image(systemName: true ? "plus" : "multiply")
                                .foregroundColor(Color(UIColor(r: 49, g: 49, b: 49, a: 1)))
                                .font(.system(size: geomtry.size.width * 0.085))
                            
                        }
                        TextField(selectChatListData["isAvailable"] as! Bool ? "메세지를 입력하세요." : "상대방의 수락을 기다리는 중입니다.", text: $firestoreViewModel.messageTextBox)
                            .disabled(selectChatListData["isAvailable"] as! Bool ? false : true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: geomtry.size.width * 0.05))
                            .cornerRadius(13, corners: .allCorners)
                        Button(action: {
                            firestoreViewModel.sendMessage() { send in
                                if send {
                                    firestoreViewModel.messageTextBox = ""
                                }
                            }
                        }){
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor($firestoreViewModel.messageTextBox.wrappedValue.count > 0 ? Color(UIColor(r: 49, g: 49, b: 49, a: 1)) : Color(UIColor(r: 49, g: 49, b: 49, a: 0.3)))
                                .font(.system(size: geomtry.size.width * 0.085))
                        }
                        .disabled($firestoreViewModel.messageTextBox.wrappedValue.count > 0 ? false : true)
                    }
                    .padding(.horizontal, geomtry.size.width * 0.03)
                    .padding(.top, 10)
                    .padding(.bottom, geomtry.size.height * 0.12)
                    .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    .position(x: geomtry.frame(in: .local).midX, y: geomtry.frame(in: .local).maxY)
            }
        }
    }
}
