//
//  FirestoreViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/05.
//

import Combine
import Firebase
//import FirebaseAuth
//import FirebaseDatabase
//import FirebaseCore
//import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift

class FirestoreViewModel: ObservableObject{
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    let db = Firestore.firestore()
    
    //현재 유저의 닉네임이 담길 변수.
    @Published var currentNickName: String = ""
    //채팅 방의 메시지 입력 텍스트필드 변수.
    @Published var sendMessageText: String = ""
    //firestore의 메시지 배열
    @Published private(set) var messages: [Messages] = []
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        getMessages()
    }
    
    //현재 유저의 닉네임 불러오는 함수.
    func currentUserNickName() -> String {
        db.collection("users").document(loginViewModel.currentUser!.uid).getDocument(){ snapshot, error in
            guard error == nil else {
                print("현재 유저 닉네임 조회 Error : \(error!)")
                return
            }
            self.currentNickName = snapshot?.get("nickname") as! String
        }
        return currentNickName
    }
    
    ///////////////////////////////////////////////////메시지 관련/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //중복없이 roomId 만드는 함수.(채팅방 생성시 사용)
    //안됨. 다른 방법 찾아볼것!
    
//    func notDuplicateRoomId(){
//        var tf: Bool = true
//        while(tf){
//            var uniqueRoomId = db.collection("chatroom").document()
//            uniqueRoomId.getDocument{ document, error in
//                guard let error = error else {
//                    print("에러났어~~ : \(String(describing: error))")
//                    return
//                }
//                guard let document = document else {
//                    print("에러 또 났어~~ : \(error)")
//                    return
//                }
//                if !document.exists{
//                    //중복 아님.
//                    uniqueRoomId.collection(document.documentID)
//                    print("생성된 roomId가 중복되지 않아 사용가능합니다.")
//                    tf = false
//                }else{
//                    //중복.
//                }
//            }
//        }
//    }
    
    
    //메시지 전송 버튼시 firestore에 저장하는 함수.
    func writeMessageToFirestore(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            return
        }
        let chatroomDoc = db.collection("chatroom").document()
        chatroomDoc.setData(["messageId" : "메시지 id", "roomId" : chatroomDoc.documentID, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "YWYO0UsL6SSASrXl43iKJNYOX0x1", "isRead" : false]){ err in
            if let err = err {
                print("메시지 전송 에러: \(err)")
            } else {
                print("메시지 성공적으로 저장완료!")
                //메시지를 저장하고 저장된 메시지를 가져와야함.
            }
        }
    }
    
    //문제있다~~~~~
    func getMessages() {
        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
        //지금은 senderId로 구분하지만, 나중에 roomId로 구분하게되면  roomId값으로 데이터들을 담은 후, senderId가 현재유저 uid와 동일하면 뷰 우측에, 아니면 좌측에 붙게 만들면 될 듯함.
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            return
        }
        db.collection("chatroom").whereField("senderId", isEqualTo: currentUser).order(by: "sendTime").addSnapshotListener { snapshot, error in
            guard error == nil else {
                print("에러다! 에러!!11 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("에러다! 에러!!22 : \(String(describing: error))")
                return
            }
            guard !documents.isEmpty else {
                print("메시지가 없음.")
                return
            }
            //messages 배열에 whereField로 걸러진 메시지 데이터들을 담는다.
            self.messages = documents.compactMap(){ document -> Messages? in
                do{
                    return try document.data(as: Messages.self)
                }catch{
                    return nil
                }
            }
        }
    }
    
    //메시지 삭제 -> ex) 방 나가기, 신고 및 차단, 계정 삭제 등
//    func deleteMessage() {
//        db.collection("chatroom").whereField("senderId", isEqualTo: loginViewModel.currentUser!.uid)
//    }
    func deleteMessagesFromFirestore() {

        self.messages.removeAll()
    }
    
    ///////////////////////////////////////////////////메시지 관련/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

//
//func getMessages() {
//    db.collection("chatroom").whereField("senderId", isEqualTo: loginViewModel.currentUser!.uid).addSnapshotListener { snapshot, error in
//        guard error == nil else {
//            print("에러다! 에러!!11 : \(String(describing: error))")
//            return
//        }
//        guard let documents = snapshot?.documents else {
//            print("에러다! 에러!!22 : \(String(describing: error))")
//            return
//        }
//        guard !documents.isEmpty else {
//            print("메시지가 없음.")
//            return
//        }
//        self.messages = documents.compactMap(){ document -> Messages? in
//            do{
//                return try document.data(as: Messages.self)
//            }catch{
//                return nil
//            }
//        }
//    }
//}
