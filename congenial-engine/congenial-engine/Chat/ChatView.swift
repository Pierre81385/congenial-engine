//
//  ChatView.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/6/24.
//

import Foundation
import SwiftUI

struct ChatView: View {
    var currentUserAccount: Account
    @ObservedObject var users = UserAccount.init(userAccount: Account(id: "", displayName: "", email: "", password: "", isActive: false), userAccounts: [], responseMessage: "", responseStatus: false)
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List(users.userAccounts){
                        user in
                        if(user.displayName != currentUserAccount.displayName)
                        {
                            NavigationLink {
                                DirectMessageView(currentUserAccount: currentUserAccount, directUserAccount: user)
                            } label: {
                                HStack {
                                    if(user.isActive){
                                        Image(systemName: "person.fill")
                                    }else{
                                        Image(systemName: "person.slash")
                                    }
                                    Text(user.displayName)
                                }
                            }
                        }
                    }
                }.onAppear{
                    users.getAllUserAccountsSnapshot()
                }
            }
        }
    }
}
