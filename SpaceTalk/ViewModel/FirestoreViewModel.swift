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
    @Published var lastMessageId: String = "" // ChatPage에서 신규 메시지 생성될때 이를 참조해서 스크롤 맨 밑으로 이동.
    
    //getMessage()의 addsnapshotlistener
    @Published var getMessageListener: ListenerRegistration?
    @Published var getFirstMessageListener: ListenerRegistration?
    
    //ChatPage의 MessageBubble 스크롤 위치 관련 변수(geoHeight + textHeight :: MessageBubble.swift)
    @Published var messageHeight : CGFloat = 0
    
    //랜덤유저 뽑을때 5회 이상 반복될 경우 alert 띄우고 멈춤
    var randomCount : Int = 0
    var userNumberSet : Set<Int> = []
    
    //getImage() 의 image
    @Published var image : UIImage?
    
    @Published var blockedUserList : [BlockUser] = []
    
    init() {
        currentUser = Auth.auth().currentUser
        currentChatList()
        getMessages()
        getFirstMessage()
    }
    
    //MessageBubble의 이미지 로딩 전후의 크기를 담고있는 geoHeight와 textHeight를 더함.
    //이 값의 변화(geo, text 중 하나 이상의 값의 변화)를 감지해서 스크롤.
    func addHeight(geo: CGFloat, text: CGFloat) {
        messageHeight = geo + text
    }
    
    //UID를 사용해서 해당 유저의 닉네임을 가져오는 함수(현재 로그인 정보 전용)
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
        
        let ref = self.db.collection("chatroom").document(roomId).collection(roomId).document()
        
        imageReference.putData(data, metadata: metaData) { (metaData, error) in
            if let error = error {
                print("이미지 업로드 에러! : \(error.localizedDescription)")
                completion(false)
            }else {
                ref.setData(["roomId" : roomId, "messageText" : "사진", "messageId" : ref.documentID, "isRead" : false, "sendTime"  : Date(), "senderId" : self.currentUser!.uid, "imageName" : imageName])
                self.db.collection("chatroom").document(roomId).updateData(["messageId" : msgId, "messageText" : "사진", "sendTime" : Date(), "recentSenderId" : self.currentUser!.uid, "imageName" : imageName])
                print("이미지 업로드 성공!")
                completion(true)
            }
        }
    }
    
    func getImage(imageName: String, completion: @escaping (Bool) -> Void) {
        if imageName != "nil" {
            let imageReference = self.storage.reference().child("images/\(self.currentRoomId)/\(imageName)")
            imageReference.getData(maxSize: 2 * 1024 * 1024) { data, error in
                guard error == nil else {
                    print("이미지 불러오기 에러! : \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                guard data != nil else {
                    print("이미지 불러오기 에러 2!")
                    return }
                let image = UIImage(data: data!)
                self.image = image
                completion(true)
            }
        }
    }
    
    func deleteImage(imageName: String) {
        let imageReference = self.storage.reference().child("images/\(self.currentRoomId)/\(imageName)")
        imageReference.delete { error in
            guard error == nil else {
                print("이미지 삭제 에러! : \(String(describing: error?.localizedDescription))")
                return
            }
            print("이미지 삭제 성공.")
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
            
            //마지막 메시지 id 담아둠 => 이 값이 바뀔 때 마다 신규 메시지 생성되었다는 것. => 스크롤 밑으로 당김.
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
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
        var randomNumber : Int = 0
        
        if self.randomCount < 5 { // 추첨 누적이 5회 미만일 경우 ==> 그대로 진행
            self.getMaxUserCount { maxUserNumber in
                for i in 1...maxUserNumber {
                    self.userNumberSet.insert(i)
                }
                //내 userNumber를 가져옴
                self.myUserNumber() { myUserNumber in
                    //랜덤으로 뽑은 숫자와 나의 userNumber와 같다면 set에서 삭제
                    self.userNumberSet.remove(myUserNumber)
                    randomNumber = self.userNumberSet.first!
                    print("현재 유저넘버 Set 현황 : \(self.userNumberSet)")
                    print("현재 Set에서 뽑은 랜덤숫자 현황 : \(randomNumber)")
                        //랜덤으로 뽑은 userNumber의 UID 가져오기
                        self.getRandomUID(userNumber: randomNumber) { randomUID in
                            if randomUID != "nil" { //뽑은 유저가 존재할 경우
                                self.isBlock(uid: randomUID) { isblock in
                                    self.amIBlocked(uid: randomUID) { amIBlocked in
                                        if !isblock && !amIBlocked { // '나'와 '뽑은 유저'가 서로 차단하지 않은 경우 ==> 성공
                                            self.randomCount = 0
                                            self.userNumberSet.removeAll()
                                            complete(randomUID)
                                        }else { // '나'와 '뽑은 유저' 둘 중 한명이라도 차단한 경우 ==> 실패
                                            self.randomCount += 1
                                            self.userNumberSet.removeAll()
                                            self.randomUid(complete: complete)
                                        }
                                    }
                                }
                            }else { //뽑은 유저가 존재하지 않을경우(유저넘버만 존재하고 나머진 nil인 경우)
                                self.randomCount += 1
                                self.userNumberSet.removeAll()
                                self.randomUid(complete: complete)
                            }
                        }
                }
            }
        }else { //추첨 누적이 5회 이상인 경우 ==> "over" 를 반환함. ==> 무전실패 alert
            self.randomCount = 0
            self.userNumberSet.removeAll()
            complete("over")
        }
    }
    
    //현재 maxUserNumber를 가져오는 함수
    func getMaxUserCount(complete: @escaping (Int) -> Void){
        var maxUserNumber : Int = 0
        //새로 가입한 유저의 정보가 새로 생성되었을때, totalusercount의 maxUserCount를 체크하기위함.
        self.db.collection("testUser").order(by: "userNumber", descending: true).limit(to: 1).getDocuments { snapshot, error in
            guard error == nil else {
                print("getRandomUID 에러!")
                return
            }
            guard snapshot != nil else {
                print("getRandomUID 에러!2")
                return
            }
            maxUserNumber = snapshot?.documents[0].data()["userNumber"] as! Int
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
        self.getDeleteChatRoomMessageId() { deleteMessageID, deleteImageID in
            print("현재 삭제할 채팅방의 채팅 메시지 ID들입니다. \(deleteMessageID)")
            if deleteMessageID.count > 0 {
                for i in 0...deleteMessageID.count - 1 {
                    self.db.collection("chatroom").document(self.currentRoomId).collection(self.currentRoomId).document(deleteMessageID[i]).delete()
                }
                if deleteImageID.count > 0 {
                    for i in 0...deleteImageID.count - 1 {
                        self.deleteImage(imageName: deleteImageID[i])
                    }
                }
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
    
    func getDeleteChatRoomMessageId(complete: @escaping ([String], [String]) -> Void) {
        var messageID : [String] = []
        var imageID : [String] = []
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
                if document.data()["imageName"] as! String != "nil" {
                    imageID.append(document.data()["imageName"] as! String)
                }
                messageID.append(document.data()["messageId"] as! String)
            }
            complete(messageID, imageID)
        }
    }
    
    
    //차단 관련 함수//////////////////////////
    
    //상대방 차단함수. (상대방을 차단하게되면 상대방의 db 차단목록에 내 uid가 올라가게 됨.
    func blockUser(blockUserUid: String, completion: @escaping (Bool) -> Void) {
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(blockUser)")
            completion(false)
            return
        }
        self.db.collection("testUser").document(self.currentUser!.uid).updateData(["blockUser" : FieldValue.arrayUnion([blockUserUid])])
        completion(true)
    }
    
    //상대방 닉네임으로 상대방의 uid 알아내는 함수
    func getBlockUserUid(nickname: String, completion: @escaping (String) -> Void) {
        var blockUserNickName : String = ""
        self.db.collection("testUser").whereField("nickname", isEqualTo: nickname).getDocuments { snapshot, error in
            guard error == nil else {
                print("getBlockUserUid error1 : \(error?.localizedDescription)")
                completion("error")
                return}
            guard snapshot != nil else {
                print("getBlockUserUid error2")
                completion("error")
                return}
            blockUserNickName = snapshot?.documents[0].get("uid") as! String
            completion(blockUserNickName)
        }
    }
    
    //랜덤으로 뽑은 유저(uid)가 내 blockUser 배열에 존재하는지 확인하는 함수.
    func isBlock(uid: String, completion: @escaping (Bool) -> Void) {
        var isBlock : Bool = false
        var blockArray : [String] = []
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(blockUser)")
            completion(false)
            return
        }
        self.db.collection("testUser").document(self.currentUser!.uid).getDocument { snapshot, error in
            guard error == nil else {
                print("차단 불러오기 에러 : \(error?.localizedDescription)")
                return
            }
            guard snapshot != nil else {
                print("차단 목록 비어있음!")
                return
            }
            
            blockArray = snapshot?.data()!["blockUser"] as! Array<String>
            isBlock = blockArray.contains(uid)
            completion(isBlock)
        }
    }
    
    //랜덤으로 뽑은 유저의 blockUser 배열에 '내'가 존재하는지 확인하는 함수.
    func amIBlocked(uid: String, completion: @escaping (Bool) -> Void) {
        var isBlock : Bool = false
        var blockArray : [String] = []
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(amIBlocked)")
            completion(false)
            return
        }
        self.db.collection("testUser").document(uid).getDocument { snapshot, error in
            guard error == nil else {
                print("차단 불러오기 에러 : \(error?.localizedDescription)")
                return
            }
            guard snapshot != nil else {
                print("차단 목록 비어있음!")
                return
            }
            blockArray = snapshot?.data()!["blockUser"] as! Array<String>
            isBlock = blockArray.contains(self.currentUser!.uid)
            completion(isBlock)
        }
    }
    
    func convertUidToNickname(uid: String, completion: @escaping (String) -> Void) {
        var nickname : String = ""
        self.db.collection("testUser").document(uid).getDocument { snapshot, error in
            guard error == nil else {
                print("convertUidToNickname 에러! : \(error?.localizedDescription)")
                return
            }
            guard snapshot != nil else {
                return
            }
            nickname = snapshot?.data()!["nickname"] as! String
            completion(nickname)
        }
    }
    
    //차단유저 목록 가져오기
    func getBlockUserList(completion: @escaping (Bool) -> Void) {
        var blockedUserUIDArray : [String] = []
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(getBlockUserList)")
            completion(false)
            return
        }
        self.db.collection("testUser").document(self.currentUser!.uid).getDocument { snapshot, error in
            guard error == nil else {
                print("getBlockUserList 에러! : \(error?.localizedDescription)")
                completion(false)
                return
            }
            guard snapshot != nil else {
                completion(false)
                return
            }
            blockedUserUIDArray = snapshot?.data()!["blockUser"] as! Array<String>
            for uid in blockedUserUIDArray {
                self.convertUidToNickname(uid: uid) { nickname in
                    self.blockedUserList.append(BlockUser(blockUserNickName: nickname, blockUserUID: uid))
                }
            }//for
            completion(true)
        }//getdocument
    }//getBlockUserList
    
    //차단유저 해제
    func removeList(at offsets: IndexSet) {
        var uid : String = ""
        guard self.currentUser != nil else {
            print("firestoreVM currentUser 값이 비어있습니다.(blockUser)")
            return
        }
        guard let index = offsets.first else {return}
        print("deleting \(self.blockedUserList[index])")
        uid = self.blockedUserList[index].blockUserUID
        self.blockedUserList.remove(atOffsets: offsets)
        self.db.collection("testUser").document(self.currentUser!.uid).updateData(["blockUser" : FieldValue.arrayRemove([uid])])
    }
    
    
}
