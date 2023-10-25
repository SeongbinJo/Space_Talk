//
//  MessageBubble.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/24.
//

import Foundation
import SwiftUI

struct MessageBubble: View {
    
    @EnvironmentObject var loginViewModel : LoginViewModel
    @EnvironmentObject var firestoreViewModel : FirestoreViewModel

    var message: Messages
    
    @State var geoHeight : CGFloat = 0 // 사진에 따른 높이
    @State var textHeight : CGFloat = 0 // 텍스트에 따른 높이
    @State var nilImageHeight : CGFloat = 0 // 사진이 로딩되기 전 'photo' 이미지의 높이
    @State var uiImage : UIImage?
    
    @State var selectedImage : UIImage?
    @State var goToImagePage : Bool = false


    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack(alignment: .bottom, spacing: 1){
//                    Text(message.isRead ? "" : "1")
//                        .foregroundColor(.yellow)
//                        .font(.system(size: geometry.size.width * 0.03))
//                        .frame(width: message.senderId == loginViewModel.currentUser!.uid ? geometry.size.width * 0.03 : 0)
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.024))
                        .frame(width: message.senderId == loginViewModel.currentUser!.uid ? geometry.size.width * 0.3 : 0)
                    if message.imageName != "nil" {
                        if self.uiImage != nil {
                            Image(uiImage: self.uiImage!)
                                .resizable()
                                .frame(width: geometry.size.width * 0.4, height: self.uiImage!.size.height * (geometry.size.width * 0.4/self.uiImage!.size.width))
                                .background {
                                    message.senderId == loginViewModel.currentUser!.uid ? Color.yellow : Color.white
                                    GeometryReader { geo in
                                        Text("")
                                            .onAppear{
                                                self.textHeight = geo.size.height
                                            }
                                    }
                                }
                                .onTapGesture {
                                }
                                .cornerRadius(5, corners: .allCorners)
                                .padding(message.senderId != loginViewModel.currentUser!.uid ? .leading : .trailing, 10)
                        }else {
                            Image(uiImage: UIImage(systemName: "photo")!)
                                .resizable()
                                .padding(5)
                                .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                .background {
                                    message.senderId == loginViewModel.currentUser!.uid ? Color.yellow : Color.white
                                    GeometryReader { geo in
                                        Text("")
                                            .onAppear{
                                                self.textHeight = geo.size.height
                                            }
                                    }
                                }
                                .cornerRadius(5, corners: .allCorners)
                                .padding(message.senderId != loginViewModel.currentUser!.uid ? .leading : .trailing, 10)
                        }
                    }else {
                        Text(message.messageText)
                            .font(.system(size: geometry.size.width * 0.04))
                            .padding(7)
                            .background{
                                message.senderId == loginViewModel.currentUser!.uid ? Color.yellow : Color.white
                                GeometryReader{ geo in
                                    Text("")
                                        .onAppear{
                                            self.textHeight = geo.size.height
                                        }
                                }
                            }
                            .cornerRadius(5, corners: .allCorners)
                            .padding(message.senderId != loginViewModel.currentUser!.uid ? .leading : .trailing, 10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.024))
                        .frame(width: message.senderId != loginViewModel.currentUser!.uid ? geometry.size.width * 0.3 : 0)
//                    Text(message.isRead ? "" : "1")
//                        .foregroundColor(.yellow)
//                        .font(.system(size: geometry.size.width * 0.03))
//                        .frame(width: message.senderId != loginViewModel.currentUser!.uid ? geometry.size.width * 0.03 : 0)
                }
                // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
                .frame(maxWidth: geometry.size.width * 0.9, maxHeight: .infinity, alignment: message.senderId == loginViewModel.currentUser!.uid ? .trailing : .leading)
            }
            .onAppear {
                firestoreViewModel.getImage(imageName: self.message.imageName) { complete in
                    if complete {
                        self.uiImage = firestoreViewModel.image
                        self.geoHeight = self.uiImage!.size.height * (geometry.size.width * 0.4/self.uiImage!.size.width)
                    }
                }
            }
            // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: message.senderId == loginViewModel.currentUser!.uid ? .trailing : .leading)
        }
        .frame(height: message.imageName != "nil" ? (self.uiImage != nil ? self.geoHeight : self.textHeight) : self.textHeight)
    }
    
}

