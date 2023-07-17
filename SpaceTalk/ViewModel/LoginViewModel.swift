//
//  FirebaseLoginViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import SwiftUI


class LoginViewModel: ObservableObject{

    let db = Firestore.firestore()
    
    @Published var currentUser: User?
    
    //회원가입 페이지 텍스트필드
    @Published var signUpNickname: String = ""
    @Published var signUpEmail: String = ""
    @Published var signUpPassword: String = ""
    @Published var signUpPasswordCheck: String = ""
    //회원가입 페이지 '가입' 버튼 비/활성화
    @Published var emailCheck = false
    @Published var pwdCheck = false
    @Published var pwdSecondCheck = false
    @Published var nickNameCheck = false
    
    //회원가입 페이지 - 닉네임/이메일 중복확인 alert창 bool
    @Published var showNickNameResult: Bool = false
    @Published var showEmailResult: Bool = false
    
    //회원가입 페이지 - 닉네임/이메일 중복확인 bool
    @Published var isAlreadyNickName: Bool = true
    @Published var isAlreadyEmail: Bool = true
    
    //채팅방이 열리면 MainPage의 하단 바가 사라지게 하기위한 변수.
    @Published var isChatRoomOpened: Bool = false
    
    
    //필드값이 nil인 도큐먼트의 UserNumber값
    @Published var nilUserNumber = 0
    @Published var nilUserUid = ""
    //현재 유저들이 가진 userNumber중 가장 큰 수를 담기 위함. -> 이 수를 사용해서 랜덤으로 유저를 뽑을 것임.
    @Published var maxUserCount = 0
    
    
    init() {
        currentUser = Auth.auth().currentUser
    }

    //combine 메모리 누수 방지?
    private var cancellables: Set<AnyCancellable> = []
    
    //이메일 유효성 검사
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: signUpEmail)
    }
    
    //닉네임 유효성 검사
    func isValidNickName() -> Bool {
        let nickNameRegex = "[A-Z0-9a-z가-힣]{1,10}"
        let nickNamePredicate = NSPredicate(format: "SELF MATCHES %@", nickNameRegex)
        return nickNamePredicate.evaluate(with: signUpNickname)
    }
    
    //비밀번호 유효성 검사
    func isValidPassword() -> Bool {
        return signUpPassword.count >= 8
    }
    
    //비밀번호 일치 불일치
    func isSamePassword() -> Bool {
        return signUpPassword == signUpPasswordCheck
    }
    
    //firebase User 등록(회원가입)
//    func registerUser(completion: @escaping (Bool) -> Void) {
//        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPasswordCheck) { registerResult, error in
//            //등록 성공시 result에 값이 담기고, error엔 nil이 ,, 등록 실패시 result에 nil이 error엔 에러값이 담긴다.
//            guard let newUser = registerResult?.user else {return}
//            guard error == nil else {
//                completion(false)
//                print("Error : \(error!.localizedDescription)")
//                return
//            }
//            self.currentUser = newUser
//                    self.currentUser = nil
//            newUser.sendEmailVerification{ error in
//                if let error = error {
//                    print("이메일 전송 에러 : \(error.localizedDescription)")
//                }else{
//                    print("이메일 전송 성공!!")
//                }
//            }
//            completion(true)
//        }
//    }
    
    //회원가입 페이지에서 입력된 정보 firestore에 저장.
//    func writeFirestoreUser(completion: @escaping (Bool) -> Void){
//        var totalusercount:Int = 0
//        db.collection("totalusercount").document("totalusercount").getDocument{ snapshot, error in
//            if error == nil{
//                totalusercount = snapshot?.get("usercount") as! Int
//            }else{
//                print("총 유저수 가져오기 에러.")
//            }
//        }
//        db.collection("users").document(currentUser?.uid ?? "정보없음").setData(["uid" : currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date(), "userNumber" : totalusercount,"selectChatRoomId" : "선택되지 않음"]) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//                completion(false)
//            } else {
//                print("Firestore 쓰기 완료!!")
//                completion(true)
//                //회원가입 후, 로그아웃 처리를 해주지 않으면 앱 재시작 또는 앱 재설치 했을 때 회원가입했던 정보로 자동 로그인 되어 버린다.
////                self.logoutUser()
//            }
//        }
//    }
    
//    func writeRegisterUser(completion: @escaping (Bool) -> Void){
//        //필드값이 nil인 도큐먼트의 UserNumber값
//        var nilUserNumber = 0
//        var nilUserUid = ""
//        //현재 유저들이 가진 userNumber중 가장 큰 수를 담기 위함. -> 이 수를 사용해서 랜덤으로 유저를 뽑을 것임.
//        var maxUserCount = 0
//        //uid 필드 값이 nil인 데이터 찾기.
//        db.collection("users").order(by: "userNumber").whereField("uid", isEqualTo: "nil").limit(to: 1).getDocuments{ snapshot, error in
//            guard error == nil else {
//                completion(false)
//                return
//            }
//            //uid 필드 값이 nil인 데이터가 있다면. -> 새로 가입되는 유저의 정보를 nil인 데이터에 업데이트 시켜준다.
//            if !snapshot!.isEmpty{
//                //nilUserNumber에 '계정삭제한 유저의 userNumber'를 이어받기위해 저장한다. => 새로운 유저는 계정삭제한 유저의 userNumber를 계승함으로써 빈자리를 메꿈.
//                nilUserNumber = snapshot?.documents[0].data()["userNumber"] as! Int
//                //nil데이터의 documentID(=uid)또한 저장한다. => 해당 데이터를 지우기 위함.
//                nilUserUid = (snapshot?.documents[0].documentID)!
//                //usercount 1 증가.
//                self.plusTotalUserCount()
//                //nilUserNumber를 얻어냈기 때문에 지워준다.
//                self.db.collection("users").document(nilUserUid).delete()
//                //삭제한 유저들 중 첫번째 유저의 userNumber값을 저장한 nilUserNumber를 사용하여 새로운 유저의 정보를 생성한다.
//                self.db.collection("users").document(self.currentUser?.uid ?? "정보없음").setData(["uid" : self.currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date(), "userNumber" : nilUserNumber,"selectChatRoomId" : "선택되지 않음"])
//                completion(true)
//            }
//            //uid 필드 값이 nil인 데이터가 없다면. -> 새로 가입되는 유저의 정보를 새로 생성한다.
//            else{
//                //usercount 1 증가.
//                self.plusTotalUserCount()
//                //새로 가입한 유저의 정보가 새로 생성되었을때, totalusercount의 maxUserCount를 체크하기위함.
//                self.db.collection("totalusercount").document("totalusercount").getDocument{ snapshot, error in
//                    guard error == nil else { return }
//                    maxUserCount = snapshot?.get("maxUserCount") as! Int
//                }
//                //새로 가입한 유저의 정보를 새로 생성함.
//                self.db.collection("users").document(self.currentUser?.uid ?? "정보없음").setData(["uid" : self.currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date(), "userNumber" : maxUserCount + 1,"selectChatRoomId" : "선택되지 않음"])
//                self.db.collection("totalusercount").document("totalusercount").updateData(["maxUserCount" : maxUserCount + 1])
//                completion(true)
//            }
//        }
//    }
    
    func writeRegisterUser(completion: @escaping (Bool) -> Void){
        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPasswordCheck) { registerResult, error in
            //등록 성공시 result에 값이 담기고, error엔 nil이 ,, 등록 실패시 result에 nil이 error엔 에러값이 담긴다.
            guard let newUser = registerResult?.user else {return}
            guard error == nil else {
                completion(false)
                print("Error : \(error!.localizedDescription)")
                return
            }
            self.currentUser = newUser
        //uid 필드 값이 nil인 데이터 찾기.
            self.db.collection("users").order(by: "userNumber").whereField("uid", isEqualTo: "nil").limit(to: 1).getDocuments{ snapshot, error in
            guard error == nil else {
                completion(false)
                return
            }
            //uid 필드 값이 nil인 데이터가 있다면. -> 새로 가입되는 유저의 정보를 nil인 데이터에 업데이트 시켜준다.
            if !snapshot!.isEmpty{
                print("필드가 nil인 도큐멘트가 존재합니다!")
                //nilUserNumber에 '계정삭제한 유저의 userNumber'를 이어받기위해 저장한다. => 새로운 유저는 계정삭제한 유저의 userNumber를 계승함으로써 빈자리를 메꿈.
                self.nilUserNumber = snapshot?.documents[0].data()["userNumber"] as! Int
                //nil데이터의 documentID(=uid)또한 저장한다. => 해당 데이터를 지우기 위함.
                self.nilUserUid = (snapshot?.documents[0].documentID)!
                //usercount 1 증가.
                self.plusTotalUserCount()
                //nilUserNumber를 얻어냈기 때문에 지워준다.
                self.db.collection("users").document(self.nilUserUid).delete()
                //삭제한 유저들 중 첫번째 유저의 userNumber값을 저장한 nilUserNumber를 사용하여 새로운 유저의 정보를 생성한다.
                self.newUserUpdateDate(){ complete in
                    if complete{
                        self.logoutUser()
                        completion(true)
                    }
                }
            }
            //uid 필드 값이 nil인 데이터가 없다면. -> 새로 가입되는 유저의 정보를 새로 생성한다.
            else{
                print("필드가 nil인 도큐멘트는 세상에 1도 없습니다!")
                //usercount 1 증가.
                self.plusTotalUserCount()
                //새로 가입한 유저의 정보가 새로 생성되었을때, totalusercount의 maxUserCount를 체크하기위함.
                self.getMaxUserCount(){ complete in
                    if complete{
                        //새로 가입한 유저의 정보를 새로 생성함.
                        self.createNewUserData(){ complete in
                            if complete{
                                self.db.collection("totalusercount").document("totalusercount").updateData(["maxUserCount" : self.maxUserCount + 1])
                                self.logoutUser()
                                completion(true)
                            }
                        }
                    }
                }
                }
            }
            newUser.sendEmailVerification{ error in
                if let error = error {
                    print("이메일 전송 에러 : \(error.localizedDescription)")
                }else{
                    print("이메일 전송 성공!!")
                }
            }
        }
    }
    

    
    //회원가입되면 totalusercount의 숫자를 1씩 올림.
    func plusTotalUserCount(){
        var usercount = 0
        db.collection("totalusercount").document("totalusercount").getDocument{ snapshot, error in
            if let error = error{
                print("totalusercount 에러입니다.")
            }else{
                usercount = snapshot?.get("usercount") as! Int
                usercount = usercount + 1
                self.db.collection("totalusercount").document("totalusercount").updateData(["usercount" : usercount])
                print("usercount 추가")
            }
        }
    }
    
    //회원탈퇴할때 totalusercount의 숫자를 1씩 내림.
    func minusTotalUserCount(){
        var usercount = 0
        db.collection("totalusercount").document("totalusercount").getDocument{ snapshot, error in
            if let error = error{
                print("totalusercount 에러입니다.")
            }else{
                usercount = snapshot?.get("usercount") as! Int
                usercount = usercount - 1
                self.db.collection("totalusercount").document("totalusercount").updateData(["usercount" : usercount])
            }
        }
    }
    
    func getMaxUserCount(complete: @escaping (Bool) -> Void){
        //새로 가입한 유저의 정보가 새로 생성되었을때, totalusercount의 maxUserCount를 체크하기위함.
        self.db.collection("totalusercount").document("totalusercount").getDocument{ snapshot, error in
            guard error == nil else {
                complete(false)
                return }
            self.maxUserCount = snapshot?.get("maxUserCount") as! Int
            complete(true)
        }
    }
    
    func createNewUserData(complete: @escaping (Bool) -> Void){
        //새로 가입한 유저의 정보를 새로 생성함.
        self.db.collection("users").document(self.currentUser?.uid ?? "uid가 비었음"
        ).setData(["uid" : self.currentUser?.uid ?? "uid가 비었음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date(), "userNumber" : self.maxUserCount + 1,"selectChatRoomId" : "선택되지 않음"]){ error in
            if error != nil{
                complete(false)
            }else{
                complete(true)
            }
        }
    }
    
    func newUserUpdateDate(completion: @escaping (Bool) -> Void){
        self.db.collection("users").document(self.currentUser?.uid ?? "정보없음").setData(["uid" : self.currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date(), "userNumber" : self.nilUserNumber,"selectChatRoomId" : "선택되지 않음"]){ error in
            if error != nil{
                completion(false)
            }else{
                completion(true)
            }
        }
    }

    
    //로그인
    //로그인 성공시 현재 유저 정보(uid)가 저장되고 성공여부가 bool값으로 return 됨.
    //@escaping -> 일반적으로 비동기 처리할때 사용한다 -> 예를들어 http요청시 언제 답이 올지 모른다 -> loginUser함수 밖에서 비동기적으로 실행이 가능하다!
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { loginResult, error in
            if error == nil{
                if loginResult!.user.isEmailVerified{
                    self.currentUser = loginResult?.user
                    self.db.collection("users").document(self.currentUser!.uid).getDocument{ snapshot, error in
                        if error != nil{
                            print("로그인 에러.. 입력한 정보가 firestore에 존재하지않음.")
                        }else{
                            if snapshot?.data()?.count == 1{
                                completion(true)
                                print("이메일 인증을 완료한 이용자 입니다. 로그인 합니다.")
                            }
                        }
                    }
                }else{
                    completion(false)
                    print("이메일 미인증 유저입니다. 로그인 불가!")
                }
            }else{
                completion(false)
                print("ID 또는 PASSWORD가 잘못되었습니다.")
            }
        }
    }
    
    //로그아웃
    func logoutUser(){
        try? Auth.auth().signOut()
        self.currentUser = nil
        print("파이어베이스 로그아웃 처리 완료")
        print("내 현재정보 : \(self.currentUser?.uid ?? "정보없음")")
    }
    
    //계정탈퇴시 해당 유저정보 업데이트.
    func deleteUser(){
        db.collection("users").document(self.currentUser!.uid).updateData(["uid" : "nil", "email" : "nil", "nickname" : "nil", "registerDate" : Date(), "selectChatRoomId" : "선택되지 않음"]){ error in
            if error == nil{
                print("계정탈퇴 업데이트 성공!")
                self.minusTotalUserCount()
                self.currentUser?.delete()
                self.logoutUser()
            }else{
                print("계정탈퇴 업데이트 실패.")
                print("error : \(error?.localizedDescription)")
            }
        }
    }
    
    //회원탈퇴
//    func deleteUser(){
//        if currentUser != nil {
//            db.collection("users").document(self.currentUser!.uid).delete(){ error in
//                if let error = error{
//                    print("Delete Error : \(error.localizedDescription)")
//                }else{
//                    print("해당 유저 Firestore 정보 삭제완료!")
//                    self.currentUser?.delete()
//                    self.minusTotalUserCount()
//                    self.logoutUser()
//                }
//            }
//        }
//        print("계정삭제 완료")
//        print("내 현재정보 : \(self.currentUser?.uid ?? "정보없음")")
//    }
    
    
    //인증 이메일 보내는 함수
    func sendCertifyEmail(){
        guard self.currentUser == Auth.auth().currentUser else {
            print("Firebase에 등록된 유저가 아님.")
            return
        }
        }
    
    //메인화면 텍스트 에디터 placeholder 위함. 텍스트.count 0일 경우. 보이게끔.
    func textFieldPlaceHolder(sendText: String) -> Bool {
        return sendText.count == 0
    }
    
    
    //String 값에 따라 다른 화면이 호출됨. -> 메인화면의 커스텀 탭뷰 기능임.
    func changeTabView(tabindex: String, loginViewModel: LoginViewModel, firestoreViewModel: FirestoreViewModel, loginToMainPageActive: Binding<Bool>) -> some View{
        switch tabindex{
        case "home":
            return AnyView(HomePage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, loginToMainPageActive: loginToMainPageActive))
//            return AnyView(HomePagePostBox(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, postBoxZindex: .constant(1)))
        case "chatList":
            return AnyView(ChatListpage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel))
        case "setting":
            return AnyView(SettingPage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, loginToMainPageActive: loginToMainPageActive))
        default:
            return AnyView(HomePage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, loginToMainPageActive: loginToMainPageActive))
        }
    }
    
    //isChatRoomOpened 변수를 toggle하기위한 함수.
    func isChatRoomOpenedToggle(){
        isChatRoomOpened.toggle()
    }
    
//    닉네임 중복 확인해주는 함수.
    func isNickNameAlreadyUsed(completion: @escaping (Bool) -> Void){
        db.collection("users").whereField("nickname", isEqualTo: self.signUpNickname).getDocuments(){ snapshot, error in
            guard error == nil else {
                print("닉네임 중복 Error : \(error!)")
                completion(false)
                return
            }
            if snapshot!.isEmpty{
                print("해당 닉네임이 중복되지 않음.")
                completion(false)
            }else{
                print("해당 닉네임이 이미 존재함.")
                completion(true)
            }
        }
    }

    
    //이메일 중복 확인해주는 함수.
    func isEmailAlreadyUsed(completion: @escaping (Bool) -> Void){
        db.collection("users").whereField("email", isEqualTo: self.signUpEmail).getDocuments(){ snapshot, error in
            guard error == nil else {
                print("이메일 중복 Error : \(error!)")
                completion(false)
                return
            }
            if snapshot!.isEmpty{
                print("해당 이메일이 중복되지 않음.")
                completion(false)
            }else{
                print("해당 이메일이 이미 존재함.")
                completion(true)
            }
        }
    }
    
    }//LoginViewModel
