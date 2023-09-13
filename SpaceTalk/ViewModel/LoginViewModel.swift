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


//로그인, 회원가입, 계정탈퇴, HomePage의 무전기의 이름 // 까지 담은 ViewModel.
class LoginViewModel: ObservableObject{
    
    //Firestore DB
    let db = Firestore.firestore()
    
    //Firebase Auth 유저 정보
    @Published var currentUser: User?
    
    //LoginPage////////////////////
    @Published var email : String = ""
    @Published var password : String = ""
    
    //SignUpPage////////////////////
    @Published var signUpNickname : String = ""
    @Published var signUpEmail : String = ""
    @Published var signUpPassword : String = ""
    @Published var signUpPasswordCheck : String = ""
    //회원가입 페이지 '가입' 버튼 비/활성화
    @Published var emailCheck : Bool = false
    @Published var pwdCheck : Bool = false
    @Published var pwdSecondCheck : Bool = false
    @Published var nickNameCheck : Bool = false
    
    //HomePage의 무전기 닉네임
    @Published var currentNickname: String = ""
    @Published var currentEmail: String = ""
    
    //새로 생성되는 유저의 UserNumber를 입력하기위함 -> maxUserNumber + 1
//    @Published var maxUserNumber : Int = 0
    //탈퇴하여 빈자리가 된 유저 데이터의 UID -> 이 UID를 사용하여 해당
    @Published var nilUserNumber : Int = 0
    @Published var nilUserUid : String = ""
    
    //유저정보 초기화
    init() {
        currentUser = Auth.auth().currentUser
    }

    
    //회원가입////////////////////
    func signUp(complete: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPasswordCheck) { signUpResult, error in
            guard error == nil else {
                print("회원가입 에러! : \(String(describing: error?.localizedDescription))")
                complete(false)
                return
            }
            guard let user = signUpResult?.user else {
                print("회원가입 에러! : \(String(describing: error?.localizedDescription))")
                complete(false)
                return
            }
            
            self.currentUser = user

            //uid 필드 값이 nil인 유저 데이터 찾기
            self.db.collection("testUser").order(by: "userNumber").whereField("uid", isEqualTo: "nil").limit(to: 1).getDocuments { snapshot, error in
                guard error == nil else {
                    print("error : \(String(describing: error?.localizedDescription))")
                    complete(false)
                    return
                }
                
                if snapshot!.isEmpty {
                    //새로 만들어야함
                    print("nil값인 데이터가 없어~")
                    //유저 수 1증가
                    self.plusTotalUserCount()
                    //현재 가장 높은 maxUserNumber 가져옴
                    self.getMaxUserCount() { maxUserNumber in
                        //maxUserNumber에 += 1 해서 저장한다.
                        self.updateMaxNumber(maxUserNumber: maxUserNumber + 1)
                        //maxUserNumber + 1을 userNumber로 사용해 데이터 생성
                        self.createNewUserData(maxUserNumber: maxUserNumber + 1) { create in
                            if create {
                                //로그아웃 처리
                                self.signOut()
                                complete(true)
                            }
                        }
                    }
                }else {
                    //usernumber 상속받고 새로 만들어야함, 기존 데이터 삭제도 해야함
                    print("nil값인 데이터가 존재해~")
                    //유저 수 1증가
                    self.plusTotalUserCount()
                    //빈자리 유저 데이터의 userNumber를 가져온다.
                    self.nilUserNumber = snapshot?.documents[0].data()["userNumber"] as! Int
                    //쓸모없어진 빈자리 데이터는 삭제한다.
                    self.db.collection("testUser").document((snapshot?.documents[0].documentID)!).delete()
                    //가져온 userNumber를 사용해 새 데이터 생성한다.
                    self.newUserUpdateDate() { update in
                        if update {
                            //로그아웃 처리
                            self.signOut()
                            complete(true)
                        }
                    }
                }
                

            }
//            user.sendEmailVerification { error in
//                guard error == nil else {
//                    print("이메일 전송 에러! : \(String(describing: error?.localizedDescription))")
//                    return
//                }
//                print("인증 메일을 성공적으로 발송했습니다!")
//            }

            print("회원가입 성공!")
        }
    }
    
    func updateMaxNumber(maxUserNumber: Int) {
        self.db.collection("totalUserCount").document("totalUserCount").updateData(["maxUserNumber" : maxUserNumber])
        print("실행되었다! maxUserNumber!!!")
    }
    
    //유저 수 관리(signUP과 연관)//////////////////////////////////
    //새로운 유저의 데이터가 생성되면 userCount를 1 올림
    func plusTotalUserCount(){
        var usercount = 0
        db.collection("totalUserCount").document("totalUserCount").getDocument{ snapshot, error in
            if error != nil{
                print("totalUserCount 에러입니다.")
            }else{
                usercount = (snapshot?.get("userCount") as! Int) + 1
                self.db.collection("totalUserCount").document("totalUserCount").updateData(["userCount" : usercount])
                print("usercount 추가")
            }
        }
    }
    
    //유저가 계정탈퇴를하면 userCount를 1 내림
    func minusTotalUserCount(){
        var usercount = 0
        db.collection("totalUserCount").document("totalUserCount").getDocument{ snapshot, error in
            if error != nil{
                print("totalUserCount 에러입니다.")
            }else{
                usercount = snapshot?.get("userCount") as! Int
                usercount = usercount - 1
                self.db.collection("totalUserCount").document("totalUserCount").updateData(["userCount" : usercount])
            }
        }
    }
    
    //현재 제일 높은 userNumber를 구하는 함수 -> 제일 높은 userNumber에 1을 더해서 새로 생성되는 유저의 userNumber로 부여.
    func getMaxUserCount(complete: @escaping (Int) -> Void){
        var maxUserNumber : Int = 0
        //새로 가입한 유저의 정보가 새로 생성되었을때, totalusercount의 maxUserCount를 체크하기위함.
        self.db.collection("totalUserCount").document("totalUserCount").getDocument{ snapshot, error in
            guard error == nil else {
                complete(0)
                return }
            maxUserNumber = snapshot?.get("maxUserNumber") as! Int
            complete(maxUserNumber)
        }
    }
    
    
    //유저의 데이터를 새로 생성하는 함수
    func createNewUserData(maxUserNumber: Int, complete: @escaping (Bool) -> Void){
        //새로 가입한 유저의 정보를 새로 생성함.
        self.db.collection("testUser").document(self.currentUser?.uid ?? "uid가 비었음"
        ).setData(["uid" : self.currentUser?.uid ?? "uid가 비었음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "signUpDate" : Date(), "userNumber" : maxUserNumber]){ error in
            if error != nil{
                complete(false)
            }else{
                complete(true)
            }
        }
    }
    
    //빈자리 유저 데이터의 userNumber를 이용해 새 유저 데이터 생성
    func newUserUpdateDate(completion: @escaping (Bool) -> Void){
        self.db.collection("testUser").document(self.currentUser?.uid ?? "정보없음").setData(["uid" : self.currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "signUpDate" : Date(), "userNumber" : self.nilUserNumber]){ error in
            if error != nil{
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    
    
    //로그인////////////////////
    func signIn(complete: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: self.email, password: self.password) { signInResult, error in
            guard error == nil else {
                print("로그인 에러! : \(String(describing: error?.localizedDescription))")
                complete(false)
                return
            }
            guard let user = signInResult?.user else {
                print("로그인 에러!")
                complete(false)
                return
            }
            
            //이메일 인증확인
//            if user.isEmailVerified {
                //로그인한 유저정보 저장
                self.currentUser = user
                complete(true)
//            }else {
//                print("해당 이메일은 인증이 완료되지 않은 이메일입니다.")
//                complete(false)
//            }
        }
    }
    
    
    //로그아웃////////////////////
    func signOut() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        print("로그아웃 성공!")
    }
    
    //계정탈퇴////////////////////
    func deleteUser(){
        db.collection("testUser").document(self.currentUser!.uid).updateData(["uid" : "nil", "email" : "nil", "nickname" : "nil"]){ error in
            if error == nil{
                print("계정탈퇴 업데이트 성공!")

                if let user = Auth.auth().currentUser {
                    user.delete() { error in
                        if let error = error {
                            print("계정 삭제 에러! : \(error.localizedDescription)")
                        }
                        else {
                            print("firebase 계정 삭제 완료.")
                            self.minusTotalUserCount()
                            self.signOut()
                        }
                    }
                }

            }else{
                print("계정탈퇴 업데이트 실패.")
                print("error : \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
    //SignUpPage 유효성 검사.////////////////////
    //닉네임 유효성 검사
    func isValidNickname() -> Bool {
        let nickNameRegex = "[A-Z0-9a-z가-힣]{1,10}"
        let nickNamePredicate = NSPredicate(format: "SELF MATCHES %@", nickNameRegex)
        return nickNamePredicate.evaluate(with: signUpNickname)
    }
    
    //닉네임 중복 검사
    func existNickname(complete: @escaping (Bool) -> Void) {
        self.db.collection("testUser").whereField("nickname", isEqualTo: self.signUpNickname).getDocuments() { snapshot, error in
            guard error == nil else {
                print("닉네임 중복확인 에러!")
                complete(false)
                return
            }
            guard let document = snapshot else {
                print("닉네임 중복확인 에러!")
                complete(false)
                return
            }
            if document.isEmpty {
                print("사용 가능!")
                complete(true)
            }else {
                print("사용 불가능!")
                complete(false)
            }
        }
    }
    
    //이메일 유효성 검사
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: signUpEmail)
    }
    
    //이메일 중복검사
    func existEmail(complete: @escaping (Bool) -> Void) {
        self.db.collection("testUser").whereField("email", isEqualTo: self.signUpEmail).getDocuments() { snapshot, error in
            guard error == nil else {
                print("이메일 중복확인 에러!")
                complete(false)
                return
            }
            guard let document = snapshot else {
                print("이메일 중복확인 에러!")
                complete(false)
                return
            }
            if document.isEmpty {
                print("사용 가능!")
                complete(true)
            }else {
                print("사용 불가능!")
                complete(true)
            }
        }
    }
    
    
    //비밀번호 유효성 검사
    func isValidPassword() -> Bool {
        return signUpPassword.count >= 8
    }
    
    //비밀번호 일치 불일치
    func isSamePassword() -> Bool {
        return signUpPassword == signUpPasswordCheck
    }
    
    
    //HomePage의 무전기 닉네임 가져오는 함수
    func currentUserInformation(complete: @escaping (Bool) -> Void) {
        guard let currentuser = self.currentUser?.uid else {
            complete(false)
            return
        }
        db.collection("testUser").document(currentuser).getDocument(){ snapshot, error in
            guard error == nil else {
                print("현재 유저 닉네임 조회 Error : \(error!)")
                complete(false)
                return
            }
            self.currentNickname = snapshot?.get("nickname") as? String ?? "정보가 없음"
            self.currentEmail = snapshot?.get("email") as? String ?? "정보가 없음"
            complete(true)
        }
    }
    
    func testfunc() {
        self.db.collection("testUser").document(self.currentUser?.uid ?? "정보없음").getDocument { snapshot, error in
            guard error == nil else {return}
            print("loginviewmodel 현재 로그인한 유저의 정보입니다. : \(snapshot?.data())")
        }
    }
    
    }//LoginViewModel

