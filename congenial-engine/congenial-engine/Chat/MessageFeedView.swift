//
//  MessageFeedView.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/9/24.
//

import Foundation
import SwiftUI

struct MessageFeedView: View {
    var currenUserAccount: Account
    var messages: [Message]
    
    var body: some View {
        ZStack {
            List(messages) {
                message in
                if(message.sender == currenUserAccount){
                
                HStack {
                    if (message.sender.isActive) {
                        Image(systemName: "person.fill")
                    } else {
                        Image(systemName: "person.slash")
                    }
                    VStack.init(alignment: .leading) {
                        Text(message.sender.displayName).font(.headline)
                        Text(message.content)
                    }.rotationEffect(.radians(.pi))
                        .scaleEffect(x: -1, y: 1, anchor: .center)
                        Spacer()
                }
                    
                } else {
                    
                    HStack {
                        Spacer()
                        VStack.init(alignment: .trailing) {
                            Text(message.sender.displayName).font(.headline)
                            Text(message.content)
                        }
                        .rotationEffect(.radians(.pi))
                        .scaleEffect(x: -1, y: 1, anchor: .center)
                        if (message.sender.isActive) {
                            Image(systemName: "person.fill")
                        } else {
                            Image(systemName: "person.slash")
                        }
                    }
                    
                }
            }
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
        }
    }
}
