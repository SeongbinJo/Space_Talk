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
    //메시지 전송 버튼시 firestore에 저장하는 함수.
    func writeMessageToFirestore(){
        let chatroomDoc = db.collection("chatroom").document()
        chatroomDoc.setData(["messageId" : "메시지 id", "roomId" : chatroomDoc.documentID, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : loginViewModel.currentUser!.uid, "receiverId" : "YWYO0UsL6SSASrXl43iKJNYOX0x1", "isRead" : false]){ err in
            if let err = err {
                print("메시지 전송 에러: \(err)")
            } else {
                print("메시지 성공적으로 저장완료!")
                //메시지를 저장하고 저장된 메시지를 가져와야함.
            }
        }
    }
    
    //현재 접속중인 유저의 uid와 일치하는 senderid 또는 receiverid를 가진 메시지들만 조회하여 messages 배열에 시간 순서대로 집어넣는다.
    //시간 순서대로 -> ex) .order(by: timestamp)
    
    //문제있다~~~~~
    func getMessages() {
        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
        //whereField와 order를 같이 사용하면 error가 난다. -> firestore 색인 문제?
        db.collection("chatroom").whereField("senderId", isEqualTo: loginViewModel.currentUser!.uid).addSnapshotListener { snapshot, error in
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
            
            //sendTime에 따른 오름차순 정렬.
            self.messages.sort{
                $0.sendTime < $1.sendTime
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
