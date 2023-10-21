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
//    @State var selectedImageData : Data? = nil
    @State var getImage : UIImage? = nil
    @State var isImage : Bool = false
    
    var body: some View {
        GeometryReader{ geomtry in
            VStack(alignment: .leading){
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
                            firestoreViewModel.sendMessage(image: (getImage ?? UIImage(systemName: "photo"))!) { send in
                                if send {
                                    firestoreViewModel.messageTextBox = ""
                                    self.getImage = nil
                                }
                            }
                        }){
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor($firestoreViewModel.messageTextBox.wrappedValue.count > 0 ? Color(UIColor(r: 49, g: 49, b: 49, a: 1)) : (self.getImage != nil ? Color(UIColor(r: 49, g: 49, b: 49, a: 1)) : Color(UIColor(r: 49, g: 49, b: 49, a: 0.3))))
                                .font(.system(size: geomtry.size.width * 0.085))
                        }
                        .disabled($firestoreViewModel.messageTextBox.wrappedValue.count > 0 && self.getImage == nil ? false : (self.getImage != nil ? false : true))
                    }
                    .frame(height: geomtry.size.height * 0.07)
                    .padding(.horizontal, geomtry.size.width * 0.03)
                    .padding(.top, 10)
                    .padding(.bottom, geomtry.size.height * 0.01)
                    .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                    .position(x: geomtry.frame(in: .local).midX, y: geomtry.size.height * 0.98)
                    if self.isImage {
                        ZStack(alignment: .topTrailing){
                            ZStack{
                                Rectangle()
                                    .frame(width: geomtry.size.width * 0.7, height: self.getImage == nil ? geomtry.size.width * 0.7 : self.getImage!.size.height * (geomtry.size.width * 0.7/self.getImage!.size.width))
                                    .foregroundColor(Color.clear)
                                    Rectangle()
                                        .frame(width: geomtry.size.width * 0.65, height: self.getImage == nil ? geomtry.size.width * 0.65 : self.getImage!.size.height * (geomtry.size.width * 0.65/self.getImage!.size.width))
                                        .foregroundColor(Color(UIColor.lightGray))
                                        .overlay(
                                            self.getImage != nil ?
                                            Image(uiImage: getImage!)
                                                .resizable()
                                            : Image(systemName: "xmark")
                                        )
                                        .cornerRadius(10, corners: .allCorners)
                            }
                            .padding(.leading, geomtry.size.width * 0.03)
                                Button(action: {
                                    self.getImage = nil
                                    self.isImage = false
                                }){
                                    Circle()
                                        .frame(width: geomtry.size.width * 0.08, height: geomtry.size.width * 0.08)
                                        .foregroundColor(Color.white)
                                        .zIndex(1)
                                        .overlay(Image(systemName: "xmark"))
                                }
                        }
                    }
                }
                    
            }
        }
    }
}
