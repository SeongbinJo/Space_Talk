//
//  MessageTextBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct MessageTextBox: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var selectChatListData: [String : Any]
    
    @State var selectedItem : PhotosPickerItem? = nil
    @Binding var getImage : UIImage?
    @Binding var isImage : Bool
    
    @State var disableSendButton : Bool = false
    
    var body: some View {
        GeometryReader{ geomtry in
                ZStack{
                    HStack{
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Image(systemName: "photo")
                                    .foregroundColor(selectChatListData["isAvailable"] as! Bool ? (firestoreViewModel.messageTextBox.count > 0 ? Color(UIColor(r: 49, g: 49, b: 49, a: 0.3)) : Color(UIColor(r: 49, g: 49, b: 49, a: 1))) : Color(UIColor(r: 49, g: 49, b: 49, a: 0.3)))
                                    .font(.system(size: geomtry.size.width * 0.07))
                            }
                            .onChange(of: selectedItem) { newImage in
                                Task {
                                    if let data = try? await newImage?.loadTransferable(type: Data.self) {
                                        self.getImage = UIImage(data: data)
                                        self.isImage = true
                                    }
                                }
                            }
                            .disabled(selectChatListData["isAvailable"] as! Bool ? (firestoreViewModel.messageTextBox.count > 0 ? true : false) : true)
                        TextField(selectChatListData["isAvailable"] as! Bool ? (self.getImage != nil ? "이미지/메시지 만 보낼 수 있습니다." : "메세지를 입력하세요.") : "상대방의 수락을 기다리는 중입니다.", text: $firestoreViewModel.messageTextBox)
                            .disabled(selectChatListData["isAvailable"] as! Bool ? (self.getImage != nil ? true : false) : true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: geomtry.size.width * 0.04))
                            .cornerRadius(13, corners: .allCorners)
                        Button(action: {
                            self.isImage = false
                            self.disableSendButton = true
                            firestoreViewModel.sendMessage(image: (getImage ?? UIImage(systemName: "photo"))!) { send in
                                if send {
                                    firestoreViewModel.messageTextBox = ""
                                    self.getImage = nil
                                    self.disableSendButton = false
                                }else {
                                    self.disableSendButton = false
                                }
                            }
                        }){
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor($firestoreViewModel.messageTextBox.wrappedValue.count > 0 ? Color(UIColor(r: 49, g: 49, b: 49, a: 1)) : (self.getImage != nil ? Color(UIColor(r: 49, g: 49, b: 49, a: 1)) : Color(UIColor(r: 49, g: 49, b: 49, a: 0.3))))
                                .font(.system(size: geomtry.size.width * 0.085))
                        }
                        .disabled($firestoreViewModel.messageTextBox.wrappedValue.count > 0 && self.getImage == nil ? false : (self.getImage != nil ? false : true))
                        .disabled(self.disableSendButton == false ? false : true)
                    }
                    .padding(.horizontal, geomtry.size.width * 0.03)
                    .position(x: geomtry.frame(in: .local).midX, y: geomtry.frame(in: .local).midY)
                    
                }
                    
            
        }
    }
}
