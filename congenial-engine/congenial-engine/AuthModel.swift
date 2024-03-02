//
//  AuthModel.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/1/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FireAuth: ObservableObject {
    @Published var authStatus: Bool
    @Published var authErrorMessage: String
    
    init(authStatus: Bool, authErrorMessage: String) {
        self.authStatus = authStatus
        self.authErrorMessage = authErrorMessage
    }
    
    func CreateUser(email: String, password: String) {
          Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
              if error != nil {
                  self.authStatus = false
                  self.authErrorMessage = error?.localizedDescription ?? ""
              } else {
                  self.authStatus = true
                  self.authErrorMessage = "Successfully signed in!"
              }
          }
        }
    
    
    func GetCurrentUser() -> User {
        if Auth.auth().currentUser != nil {
            self.authStatus = true
            self.authErrorMessage = "Found user uid: \(String(describing: Auth.auth().currentUser?.uid))"
            return Auth.auth().currentUser!
        } else {
            self.authStatus = false
            self.authErrorMessage = "User not found!"
            return Auth.auth().currentUser!
        }
    }
    
    func SignInWithEmailAndPassword(email: String, password: String) {
        
               Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                   if error != nil {
                       self.authStatus = false
                       self.authErrorMessage = error?.localizedDescription ?? ""
                   } else {
                       self.authStatus = true
                       self.authErrorMessage = "Successfully signed in!"
                   }
               }
           
    }
    
    func SendEmailVerfication(){
        Auth.auth().currentUser?.sendEmailVerification { error in
            if error != nil {
                self.authStatus = false
                self.authErrorMessage = error?.localizedDescription ?? ""
            } else {
                self.authStatus = true
                self.authErrorMessage = "Email verification sent!"
            }
        }
    }
    
    func UpdateEmail(email: String) {
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if error != nil {
                self.authStatus = false
                self.authErrorMessage = error?.localizedDescription ?? ""
            } else {
                self.authStatus = true
                self.authErrorMessage = "Email updated!"
            }
        }
    }
    
    func UpdatePassword(password: String) {
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if error != nil {
                self.authStatus = false
                self.authErrorMessage = error?.localizedDescription ?? ""
            } else {
                self.authStatus = true
                self.authErrorMessage = "Password updated!"
            }
        }
    }
    
    func SendPasswordReset(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                self.authStatus = false
                self.authErrorMessage = error?.localizedDescription ?? ""
            } else {
                self.authStatus = true
                self.authErrorMessage = "Password reset sent to \(email)!"
            }
        }
    }
    
    func DeleteCurrentUser() {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if error != nil {
                self.authStatus = false
                self.authErrorMessage = error?.localizedDescription ?? ""
            } else {
                self.authStatus = true
                self.authErrorMessage = "User deleted!"
            }
        }
    }
    
    func SignOut(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            self.authStatus = true
            self.authErrorMessage = "Signed out!"
        } catch let signOutError as NSError {
            self.authStatus = false
            self.authErrorMessage = signOutError.description
        }
    }
}
