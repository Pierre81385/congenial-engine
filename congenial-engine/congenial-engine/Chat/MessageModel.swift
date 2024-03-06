//
//  MessageModel.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/3/24.
//

import Foundation
import FirebaseFirestore

//the message sent by a user
struct Message: Codable, Identifiable, Equatable {
    var id: String //set as timestamp toString on creation
    var content: String
    var sender: Account
    var attachment: String
}

//the container for the messages sent back and forth
struct MessageCollection: Codable, Identifiable, Equatable {
    var id: String //set as timestamp toString on creation
    var users: [Account]
    var messages: [Message]
    var isPrivate: Bool
    var accessCode: String
}

class ChatMessage: ObservableObject {
    @Published var messageCollection: MessageCollection
    @Published var messageCollections: [MessageCollection]
    @Published var chatMessage: Message
    @Published var chatMessages: [Message]
    @Published var responseMessage: String
    @Published var responseStatus: Bool
    
    private var db = Firestore.firestore()
    
    init(messageCollection: MessageCollection, messageCollections: [MessageCollection], chatMessage: Message, chatMessages: [Message], responseMessage: String, responseStatus: Bool) {
        self.messageCollection = messageCollection
        self.messageCollections = messageCollections
        self.chatMessage = chatMessage
        self.chatMessages = chatMessages
        self.responseMessage = responseMessage
        self.responseStatus = responseStatus
    }
    
    func createMessageCollection() {
        let docRef = db.collection("chat").document(self.messageCollection.id)
        do {
            try docRef.setData(from: self.messageCollection)
            self.responseMessage = "message collection created!"
            self.responseStatus = true
        } catch {
            self.responseMessage = "Error: \(error.localizedDescription)"
            self.responseStatus = false
        }
    }
    
    func addMessageCollectionUser(id: String, user: Account) {
        let docRef = db.collection("chat").document(id)
        
        docRef.updateData([
            "users": FieldValue.arrayUnion([user])
          ])
        self.responseMessage = "user added!"
        self.responseStatus = true
        
    }
    
    func removeMessageCollectionUser(id: String, user: Account) {
        let docRef = db.collection("chat").document(id)
        
        docRef.updateData([
            "users": FieldValue.arrayRemove([user])
          ])
        self.responseMessage = "user removed!"
        self.responseStatus = true
    }
    
    func createMessage(id: String, message: ChatMessage) {
        let docRef = db.collection("chat").document(id)
        
            docRef.updateData([
                "messages": FieldValue.arrayUnion([message])
              ])
            self.responseMessage = "message sent!"
            self.responseStatus = true
    }
    
    func getAllMessageCollectionsSnapshot() {
        db.collection("chat")
            .addSnapshotListener {
                querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    self.responseMessage = "Oops! Failed to get all message collections! Error: \(error!.localizedDescription)"
                    self.responseStatus = false
                    return
                }
                self.messageCollections = documents.compactMap { queryDocumentSnapshot -> MessageCollection? in
                    return try? queryDocumentSnapshot.data(as: MessageCollection.self)
                }
                self.responseMessage = "Found userAccounts!"
                self.responseStatus = true
            }
    }
    
    func deleteMessageCollectionById(id: String) async {
        let docRef = db.collection("chats").document(id)
        
        do {
          try await docRef.delete()
            self.responseMessage = "Message collection deleted!"
            self.responseStatus = true
          print("Document successfully removed!")
        } catch {
            self.responseMessage = "Oops! Failed delete message collection! Error: \(error.localizedDescription)"
            self.responseStatus = false
        }
    }
    
}
