//
//  DirectMessageView.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/6/24.
//

import Foundation
import SwiftUI

struct DirectMessageView: View {
    var currentUserAccount: Account
    var directUserAccount: Account
   
    @ObservedObject var messages = ChatMessage(messageCollection: MessageCollection(id: "", users: [], messages: [], isPrivate: true, accessCode: ""), messageCollections: [], chatMessage: Message(id: Int(Date().timeIntervalSince1970), content: "", sender: Account(id: "", displayName: "", email: "", password: "", isActive: false), attachment: ""), chatMessages: [], responseMessage: "", responseStatus: false)
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("DM with \(currentUserAccount.displayName) and \(directUserAccount.displayName)")
                }
            }
        }.onAppear{
            let users = [currentUserAccount, directUserAccount]
            let dmCollection = MessageCollection(id: String(currentUserAccount.id + directUserAccount.id).base64Encoded()!, users: users, messages: [], isPrivate: true, accessCode: "")
            messages.messageCollection = dmCollection
            Task {
                await messages.confirmMessageCollectionById(id: dmCollection.id)
            }
            
        }
    }
}
