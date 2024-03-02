//
//  UserModel.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/1/24.
//

import Foundation
import FirebaseFirestore

struct Account: Codable, Identifiable, Equatable {
    var id: String
    var email: String
    var password: String
    var isActive: Bool
}

class UserAccount: ObservableObject {
    @Published var userAccount: Account
    @Published var userAccounts = [Account]()
    @Published var responseMessage: String
    @Published var responseStatus: Bool
    
    private var db = Firestore.firestore()
    
    init(userAccount: Account, userAccounts: [Account], responseMessage: String, responseStatus: Bool) {
        self.userAccount = userAccount
        self.userAccounts = userAccounts
        self.responseMessage = responseMessage
        self.responseStatus = responseStatus
    }
    
    func createUserAccount(){
        let docRef = db.collection("users").document(self.userAccount.id)
        do {
            try docRef.setData(from: self.userAccount)
            self.responseMessage = "Created userAccount { id: \(self.userAccount.id), email: \(self.userAccount.email), password: \(self.userAccount.password), isActive: \(self.userAccount.isActive) }"
            self.responseStatus = true
        }
        catch {
            self.responseMessage = "Oops! Failed to create a new user account! Error: \(error.localizedDescription)"
            self.responseStatus = false
        }
       
    }
    
    func getUserAccount(id: String){
        let docRef = db.collection("users").document(id)
        docRef.getDocument(as: Account.self) { result in
          switch result {
          case .success(let userAccount):
            self.userAccount = userAccount
            self.responseMessage = "Found userAccount { id: \(self.userAccount.id), email: \(self.userAccount.email), password: \(self.userAccount.password), isActive: \(self.userAccount.isActive) }"
            self.responseStatus = true
          case .failure(let error):
            self.responseMessage = "Oops! Failed to find a user account by that id! Error: \(error.localizedDescription)"
            self.responseStatus = false
          }
        }
    }
    
    func getAllUserAccountsSnapshot(){
        db.collection("users")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    self.responseMessage = "Oops! Failed to get all user accounts! Error: \(error!.localizedDescription)"
                    self.responseStatus = false
                    return
                }
                self.userAccounts = documents.compactMap { queryDocumentSnapshot -> Account? in
                    return try? queryDocumentSnapshot.data(as: Account.self)
                }
                self.responseMessage = "Found userAccounts!"
                self.responseStatus = true
            }
    }
    
    func updateUserAccount(){
        let docRef = db.collection("users").document(self.userAccount.id)
        do {
            try docRef.setData(from: self.userAccount)
            self.responseMessage = "Updated userAccount { id: \(self.userAccount.id), email: \(self.userAccount.email), password: \(self.userAccount.password), isActive: \(self.userAccount.isActive) }"
            self.responseStatus = true
        }
        catch {
            self.responseMessage = "Error updating userAccount! Error: \(error.localizedDescription)"
            self.responseStatus = true
        }
        
    }
    
    func deleteUserAccount() async {
        let docRef = db.collection("users").document(self.userAccount.id)
        
        do {
          try await docRef.delete()
            self.responseMessage = "User account deleted!"
            self.responseStatus = true
          print("Document successfully removed!")
        } catch {
            self.responseMessage = "Oops! Failed delete userAccount! Error: \(error.localizedDescription)"
            self.responseStatus = false
        }
    }
}
