//
//  FirestoreViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/05.
//

import Combine
import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift
import FirebaseStorage


//채팅 관련한 모든 기능
class FirestoreViewModel: ObservableObject{
    
    //Firestore DB
    let db = Firestore.firestore()
    //Firebase Storage
    let storage = Storage.storage()
    
    //Firebase Auth 유저정보
    @Published var currentUser: User?

    //특정 유저의 닉네임(uid이용)
    @Published var nickname: String = ""
    //랜덤으로 뽑은 유저의 닉네임
    @Published var randomUserNickname: String = ""
    
    //HomePage 무전기 Texteditor
    @Published var firstMessageText: String = ""
    
    //현재 클릭한 채팅방의 RoomID
    @Published var currentRoomId: String = "testRoomID"
    
    //ChatPage의 채팅 메시지 입력 TextField
    @Published var messageTextBox: String = ""
    
    //우편함의 처음 온 메시지들을 표시하기 위한 배열
    @Published var firstMessages: [PushButtonMessages] = []
    //무전기의 PUSH버튼으로 생성한 채팅방
    @Published var pushButtonChatRoom: [PushButtonMessages] = []
    //우편함의 'o'버튼을 눌러 생기는 채팅방
    @Published var acceptButtonChatRoom: [PushButtonMessages] = []
    //채팅방 안의 메시지들을 담을 배열 messages.
    @Published var messages: [Messages] = []
    
    //getMessage()의 addsnapshotlistener
    @Published var getMessageListener: ListenerRegistration?
    @Published var getFirstMessageListener: ListenerRegistration?
    
    //랜덤유저 뽑을때 5회 이상 반복될 경우 alert 띄우고 멈춤
    var randomCount : Int = 0
    
    var image : UIImage?
    
    init() {
        currentUser = Auth.auth().currentUser
        currentChatList()
        getMessages()
        getFirstMessage()
    }
    
    //UID를 사용해서 해당 유저의 닉네임을 가져오는 함수
    func getNickname(uid: String, complete: @escaping (Bool) -> Void) {
        self.db.collection("testUser").document(uid).getDocument() { snapshot, error in
            guard error == nil else {
                print("getNickName 에러!")
                complete(false)
                return
            }
            guard snapshot != nil else {
                print("getNickName 에러2!")
                complete(false)
                return
            }
            self.nickname = snapshot?.data()?["nickname"] as? String ?? "nil"
            complete(true)
        }
    }
    
    //HomePage의 무전기로 첫 메시지를 PUSH해서 DB에 저장하는 함수
    func sendFirstMessageInHomePage(completion: @escaping (Bool) -> Void){
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(sendFirstMessageInHomePage)")
            completion(false)
            return
        }
        var isReady: Bool = false
        print("PUSH했을때 유저의 uid : \(self.currentUser!.uid)")
        let chatDoc = self.db.collection("chatroom").document()
        let chatroomDoc = chatDoc.collection(chatDoc.documentID).document()
        
        self.randomUid() { randomUID in
            if randomUID != "over" {
                self.getRandomUidNickname(uid: randomUID) { nicknameComplete in
                    if nicknameComplete {
                        //chatroom/roomid 의 필드 저장.(postbox 생성위함)
                        //이때 firstSenderId 필드를 추가해서 sender가 PUSH눌렀을때 이 필드 값을 참조해서 뷰에 채팅방 추가되게끔.
                        //isAvailable 필드도 추가해서 'o'눌렀을때 true로 바뀌고 이 값이 true 일 경우에 채팅 텍스트필드가 활성화 되게끔.
                        chatDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstMessageText, "sendTime" : Date(), "recentSenderId" : self.currentUser!.uid, "isRead" : false, "firstSenderId" : self.currentUser!.uid, "firstReceiverId" : randomUID, "isAvailable" : false, "isExit" : false, "firstSenderNickname" : self.nickname, "firstReceiverNickname" : self.randomUserNickname, "imageName" : "nil"]){ error in
                            if let error = error {
                                print("무전기 메시지 발송 에러1 : \(error)")
                                completion(false)
                            }else{
                                print("무전기 메시지 발송 성공!")
                                isReady = true
                            }
                        }
                        
                        //chatroom/roomid/roomid/ 필드 저장.
                        chatroomDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstMessageText, "sendTime" : Date(), "senderId" : self.currentUser!.uid, "isRead" : false, "imageName" : "nil"]){ error in
                            if let error = error {
                                print("무전기 메시지 발송 에러2 : \(error)")
                                completion(false)
                            }else{
                                print("첫 메시지 저장완료.")
                                if isReady {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }else {
                print("메시지 발송 실패(유저 찾기 5회 초과)")
                completion(false)
            }
        }
        
    }//sendFirstMessageInHomePage()
    
    
    //ChatPage에서 메시지 발신 함수
    func sendMessage(image: UIImage, complete: @escaping (Bool) -> Void) {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(sendMessage)")
            complete(false)
            return
        }
        
        let messageDoc = self.db.collection("chatroom").document(self.currentRoomId).collection(self.currentRoomId).document()
        
        if self.messageTextBox.count > 0 {
            //chatroom/roomid/roomid 에 메시지 저장. -> messageBubble에 사용.
            messageDoc.setData(["roomId" : self.currentRoomId, "messageText" : self.messageTextBox, "messageId" : messageDoc.documentID, "isRead" : false, "sendTime"  : Date(), "senderId" : self.currentUser!.uid, "imageName" : "nil"])

            self.db.collection("chatroom").document(self.currentRoomId).updateData(["messageId" : messageDoc.documentID, "messageText" : self.messageTextBox, "sendTime" : Date(), "recentSenderId" : self.currentUser!.uid, "imageName" : "nil"])
            complete(true)
        }else if image != nil {
            self.uploadImage(image: image, roomId: self.currentRoomId, msgId: messageDoc.documentID) { uploaded in
                if uploaded {
                    complete(true)
                }else {
                    complete(false)
                }
            }
        }
    }//sendMessage()
    
    
    //Firebase Storage에 이미지 저장하는 함수
    func uploadImage(image: UIImage, roomId: String, msgId: String, completion: @escaping (Bool) -> Void) {
        let data = image.jpegData(compressionQuality: 0.1)!
        let imageName = UUID().uuidString
        let imageReference = self.storage.reference().child("images/\(roomId)/\(imageName)")

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imageReference.putData(data, metadata: metaData) { (metaData, error) in
            if let error = error {
                print("이미지 업로드 에러! : \(error.localizedDescription)")
                completion(false)
            }else {
                self.db.collection("chatroom").document(roomId).collection(roomId).document().setData(["roomId" : roomId, "messageText" : "사진", "messageId" : msgId, "isRead" : false, "sendTime"  : Date(), "senderId" : self.currentUser!.uid, "imageName" : imageName])
                self.db.collection("chatroom").document(roomId).updateData(["messageId" : msgId, "messageText" : "사진", "sendTime" : Date(), "recentSenderId" : self.currentUser!.uid, "imageName" : imageName])
                print("이미지 업로드 성공!")
                completion(true)
            }
        }
    }
    
    func getImage(imageName: String, completion: @escaping (UIImage) -> Void) {
        let imageReference = self.storage.reference().child("images/\(self.currentRoomId)/\(imageName)")
        imageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard error == nil else {
//                print("이미지 불러오기 에러! : \(error.localizedDescription)")
                print("이미지 불러오기 에러! : \(String(describing: error?.localizedDescription))")
                completion(UIImage(systemName: "photo")!)
                return
            }
            guard data != nil else { 
//                print("func getImage() data 에러 : \(error!.localizedDescription)")
                print("이미지 불러오기 에러 2!")
                return }
            let image = UIImage(data: data!)
            self.image = image
            print(data)
            print(UIImage(data: data!))
            completion(self.image!)
        }
    }
    
    //해당 채팅방의 메시지들을 불러오는 함수
    func getMessages() {
        self.getMessageListener = self.db.collection("chatroom").document(self.currentRoomId).collection(self.currentRoomId).addSnapshotListener { snapshot, error in
            guard error == nil else {
                print("getMessages() 에러 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("getMessages() 에러2 : \(String(describing: error))")
                return
            }
            guard !(documents.isEmpty) else {
                self.messages.removeAll()
                return
            }
            //위 조건들을 만족하는 데이터들을 담는 코드
            self.messages = documents.compactMap(){ document -> Messages? in
                Messages(dictionaryData: document.data())
            }
            //담은 데이터들을 시간별로 정렬하는 코드
            self.messages.sort { $0.sendTime < $1.sendTime }
            
        }
    }//getMessages()
    
    
    //첫 채팅 발신함(우편함) 목록 함수
    func getFirstMessage() {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(getFirstMessage)")
            return
        }
        self.getFirstMessageListener = self.db.collection("chatroom").whereField("firstReceiverId", isEqualTo: self.currentUser!.uid).whereField("isAvailable", isEqualTo: false).addSnapshotListener { snapshot, error in
            guard error == nil else {
                print("getFirstMessage() 에러 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("getFirstMessage() 에러2 : \(String(describing: error))")
                return
            }
            guard !(documents.isEmpty) else {
                self.firstMessages.removeAll()
                return
            }
            //위 조건들을 만족하는 데이터들을 담는 코드
            self.firstMessages = documents.compactMap(){ document -> PushButtonMessages? in
                PushButtonMessages(dictionaryData: document.data())
            }
            //담은 데이터들을 시간별로 정렬하는 코드
            self.firstMessages.sort { $0.sendTime < $1.sendTime }
            print(self.firstMessages)
        }
    }//getFirstMessage()
    
    
    //ChatListPage에서 채팅방 목록 생성을 위한 함수
    func currentChatList() {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(currentChatList)")
            return
        }
        print("\(self.currentUser!.uid) 나다 임마!")
        //PUSH 버튼을 누른 유저가 본인인 경우.(첫 메시지 발신자 = 본인)
        let listener = self.db.collection("chatroom").whereField("firstSenderId", isEqualTo: self.currentUser!.uid).addSnapshotListener() { snapshot, error in
            guard error == nil else {
                print("에러!1")
                return
            }
            guard let documents = snapshot?.documents else {
                print("에러!2")
                return
            }
            guard !documents.isEmpty else {
                self.pushButtonChatRoom.removeAll()
                return
            }
            
            
            //위 조건들을 만족하는 데이터들을 담는 코드
            self.pushButtonChatRoom = documents.compactMap() { document -> PushButtonMessages? in
                PushButtonMessages(dictionaryData: document.data())
            }
            //담은 데이터들을 시간별로 정렬하는 코드
            self.pushButtonChatRoom.sort { $0.sendTime > $1.sendTime }
        }
        
        //우편함에서 'O'를 눌러 생성될 채팅방(첫 메시지 발신자 != 본인)
        let listener2 = self.db.collection("chatroom").whereField("firstReceiverId", isEqualTo: self.currentUser!.uid).whereField("isAvailable", isEqualTo: true).addSnapshotListener() { snapshot, error in
            guard error == nil else {
                print("에러!2-1")
                return
            }
            guard let documents = snapshot?.documents else {
                print("에러!2-2")
                return
            }
            guard !documents.isEmpty else {
                self.acceptButtonChatRoom.removeAll()
                return
            }
            
            //위 조건들을 만족하는 데이터들을 담는 코드
            self.acceptButtonChatRoom = documents.compactMap() { document -> PushButtonMessages? in
                PushButtonMessages(dictionaryData: document.data())
            }
            //담은 데이터들을 시간별로 정렬하는 코드
            self.acceptButtonChatRoom.sort { $0.sendTime > $1.sendTime }
        }
         
    }//currentChatList()
    
    
    
    
    
    //우편함의 리스트에서 'O'를 눌렀을 경우
    func acceptFirstMessage(roomid: String) {
        self.db.collection("chatroom").document(roomid).updateData(["isAvailable" : true])
    }
    
    //우편함의 리스트에서 'X'를 눌렀을 경우
    func refuseFirstMessage(roomid: String, messageid: String) {
        self.db.collection("chatroom").document(roomid).collection(roomid).document(messageid).delete()
        self.db.collection("chatroom").document(roomid).delete()
    }
    
    
    //random으로 유저 정하는 함수
    func randomUid(complete: @escaping (String) -> Void) {
        var randomNumber: Int = 0
        self.maxUserNumber { maxUserNumber in
            randomNumber = Int.random(in: 1...maxUserNumber)
            print("랜덤으로 뽑은 숫자는?!(1부터 \(maxUserNumber)까지) : \(randomNumber)")
            //내 userNumber를 가져옴
            self.myUserNumber() { myUserNumber in
                //랜덤으로 뽑은 숫자와 나의 userNumber와 같다면 -> 다시 뽑아야함
                if randomNumber == myUserNumber {
                    if self.randomCount < 5 {
                        print("랜덤으로 뽑은 숫자와 나의 userNumber가 같습니다. 다시 뽑습니다.")
                        //함수 다시 실행.
                        self.randomCount += 1  //randomUid 횟수 1 증가.
                        print(self.randomCount)
                        self.randomUid(complete: complete)
                    }else {
                        self.randomCount = 0
                        complete("over")
                    }
                }
                else {
                    print("랜덤으로 숫자를 뽑았습니다! 해당 userNumber를 가진 유저의 UID를 가져옵니다!")
                    //랜덤으로 뽑은 userNumber의 UID 가져오기
                    self.getRandomUID(userNumber: randomNumber) { randomUID in
                        print("랜덤으로 뽑은 유저의 UID는 : \(randomUID) 입니다!")
                        if randomUID == "nil" {
                            if self.randomCount < 5 {
                                print("랜덤으로 뽑은 유저의 UID가 잘못되었습니다! 다시 뽑습니다!")
                                self.randomCount += 1 //randomUid 횟수 1 증가.
                                print(self.randomCount)
                                self.randomUid(complete: complete)
                            }else {
                                self.randomCount = 0
                                complete("over")
                            }
                        }
                        else {
                            print("랜덤으로 뽑은 유저의 UID는 : \(randomUID) 입니다!")
                            self.randomCount = 0 //randomUid가 6회 반복되기 전에 잘 마무리 되었을 경우 0으로 초기화.
                            print(self.randomCount)
                            complete(randomUID)
                        }
                    }
                }
            }
        }
    }
    
    //현재 maxUserNumber를 가져오는 함수
    func maxUserNumber(complete: @escaping (Int) -> Void) {
        var maxUserNumber : Int = 0
        //maxUserNumber를 통해서 현재 유저가 가진 가장 높은 userNumber를 알아내고, 1~maxUserNumber까지의 숫자 중 랜덤으로 하나 골라 UID를 가져오기위함.
        self.db.collection("totalUserCount").document("totalUserCount").getDocument{ snapshot, error in
            guard error == nil else {
                print("maxUserNumber 에러")
                return }
            maxUserNumber = snapshot?.get("maxUserNumber") as! Int
            complete(maxUserNumber)
        }
    }
    
    //나의 userNumber를 가져오는 함수
    func myUserNumber(complete: @escaping (Int) -> Void) {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(myUserNumber)")
            return
        }
        var myUserNumber : Int = 0
        self.db.collection("testUser").document(self.currentUser!.uid).getDocument { snapshot, error in
            guard error == nil else {
                print("myUserNumber 에러")
                return
            }
            guard snapshot != nil else {
                print("myUserNumber snapshot 에러! \(String(describing: snapshot))")
                return
            }
            myUserNumber = snapshot?.get("userNumber") as! Int
            complete(myUserNumber)
        }
    }
    
    //특정 숫자를 userNumber로 가진 데이터의 UID가져오는 함수.
    func getRandomUID(userNumber: Int, complete: @escaping (String) -> Void) {
        var randomUID : String = ""
        self.db.collection("testUser").whereField("userNumber", isEqualTo: userNumber).getDocuments { snapshot, error in
            guard error == nil else {
                print("getRandomUID 에러!")
                return
            }
            guard snapshot != nil else {
                print("getRandomUID 에러!2")
                return
            }
            randomUID = snapshot?.documents[0].data()["uid"] as! String
            complete(randomUID)
        }
    }
    
    //랜덤으로 뽑은 UID의 닉네임을 알아내는 함수.(firstReceiverNickname)
    func getRandomUidNickname(uid: String, complete: @escaping (Bool) -> Void) {
        self.db.collection("testUser").document(uid).getDocument() { snapshot, error in
            guard error == nil else {
                print("getRandomUidNickname 에러!")
                complete(false)
                return
            }
            guard snapshot != nil else {
                print("getRandomUidNickname 에러2!")
                complete(false)
                return
            }
            self.randomUserNickname = snapshot?.data()?["nickname"] as? String ?? "nil"
            complete(true)
        }
    }
    
    
    //채팅방 삭제 ///////////////////////////////
    
    func exitChatRoom(complete: @escaping (Bool) -> Void) {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(exitChatRoom)")
            return
        }
        self.getDeleteChatRoomMessageId() { deleteMessageID in
            print("현재 삭제할 채팅방의 채팅 메시지 ID들입니다. \(deleteMessageID)")
            if deleteMessageID.count > 0 {
                for i in 0...deleteMessageID.count - 1 {
                    self.db.collection("chatroom").document(self.currentRoomId).collection(self.currentRoomId).document(deleteMessageID[i]).delete()
                }
//                deleteMessageID.removeAll()
                self.getFirstSenderId() { firstSenderId in
                    if self.currentUser!.uid == firstSenderId {
                        self.db.collection("chatroom").document(self.currentRoomId).updateData(["firstSenderId" : "nil"])
                        self.db.collection("chatroom").document(self.currentRoomId).updateData(["isExit" : true])
                        complete(true)
                    }
                    else {
                        self.db.collection("chatroom").document(self.currentRoomId).updateData(["firstReceiverId" : "nil"])
                        self.db.collection("chatroom").document(self.currentRoomId).updateData(["isExit" : true])
                        complete(true)
                    }

                }
            }
        }
    }
    
    func deleteChatRoom() {
        //채팅방의 최신 메시지를 삭제하는 부분(firestore). 이 부분으로 채팅방 목록을 불러오기 때문에 채팅방 목록을 지우는 것과 같다.
        self.db.collection("chatroom").document(self.currentRoomId).delete()
    }
    
    func isExitBool(complete: @escaping (Bool) -> Void) {
        self.db.collection("chatroom").document(self.currentRoomId).getDocument{ snapshot, error in
            guard error == nil else {
                complete(false)
                return
            }
            guard snapshot?.data() != nil else {
                print("isExit값이 존재하지 않습니다.")
                print("삭제하려는 채팅방의 roomid : \(self.currentRoomId)")
                complete(false)
                return
            }
            complete(snapshot?.data()!["isExit"] as! Bool)
        }
    }
    
    func getFirstSenderId(complete: @escaping (String) -> Void) {
        self.db.collection("chatroom").document(self.currentRoomId).getDocument{ snapshot, error in
            guard error == nil else {
                print("getFirstSenderId 에러!")
                return
            }
            guard snapshot != nil else {
                print("getFirstSenderId 에러!2")
                return
            }
            complete(snapshot?.data()!["firstSenderId"] as! String)
        }
    }
    
    func getDeleteChatRoomMessageId(complete: @escaping ([String]) -> Void) {
        var messageID : [String] = []
        db.collection("chatroom").document(self.currentRoomId).collection(self.currentRoomId).getDocuments{ snapshot, error in
            guard error == nil else {
                print("getDeleteChatRoomMessageId 에러!")
                return}
            guard snapshot != nil else {
                print("getDeleteChatRoomMessageId 에러!2")
                return
            }
            guard let documents = snapshot?.documents else {
                print("getDeleteChatRoomMessageId 에러!3")
                return
            }
            for document in documents{
                messageID.append(document.data()["messageId"] as! String)
            }
            complete(messageID)
        }
    }
    
    func testfunc() {
        self.db.collection("testUser").document(self.currentUser?.uid ?? "정보가 없음.").getDocument { snapshot, error in
            guard error == nil else {return}
            print("현재 로그인한 유저의 정보입니다. : \(snapshot?.data())")
        }
    }
    
}
