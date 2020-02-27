//
//  Conversation.swift
//  ChatFramework
//
//  Created by TRIMECH on 20/04/2018.
//  Copyright © 2018 macbook pro. All rights reserved.
// This class  is responsible to show and delete conversations//

import Foundation
import FirebaseAuth
import FirebaseDatabase

@objc public class Conversation : NSObject{
    ////////////////////////////////////////////////////////////////////////////////////////////////
                                                  //MARK: Properties//
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public let user: Users
    public var lastMessage: Message
    public var  idRoom : String
    ////////////////////////////////////////////////////////////////////////////////////////////////
                                                   //MARK: Methods//
    ////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    This method allows us to download the list of conversations
    
     //Returns : Array of conversations
    */
    public class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
   // FirebaseApp.configure()

        var conversations = [Conversation]()
        var usersArray = [Users]()
        
        var idUserConv : String?
        var idroom : String?
        if let id = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(id).observe(.childAdded, with: { (snapshot) in
               
                let value = snapshot.value as? NSDictionary
                // idroom = snapshot.key
                let toID = value?.value(forKey: "toID") as! String
                let fromID = value?.value(forKey: "fromID") as! String
                if (toID != id){
                    idUserConv = toID
                }
                else if(fromID != id){
                    
                    idUserConv = fromID
                }
               Users.GetInfoUser(forUserID: idUserConv!, completion: {(user) in
                    DispatchQueue.main.async {
                        usersArray.append(user)
                        let content = value?.value(forKey: "content") as! String
                        let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                        let decrypted = AES256CBC.decryptString(content, password: password)
                        let timestamp = value?.value(forKey: "timestamp") as! Int
                        let messageType = value?.value(forKey: "type") as! String
                        idroom = snapshot.key
                        var type = MessageType.text
                        if messageType == "photo" {
                            type = .photo
                        } else if messageType == "video" {
                            type = .video
                        }
                        else if messageType == "location" {
                            type = .location
                        }
                        let isRead = value?.value(forKey: "isRead") as! Bool
                        let message = Message.init(type: type, content: decrypted as Any, owner:.receiver , timestamp: timestamp, isRead: isRead)
                        let conversation = Conversation.init(user: user, lastMessage: message , idRoom :idroom!)
                        
                        conversations.append(conversation)
                        completion(conversations)
                    } })  })}
        
    }
    /**
     This method allows us to delete conversation
     
     - Parameter idRoom: The id of conversation(String).
     */
    public class func DeleteConversation(idRoom : String)  {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(currentUserID).child(idRoom).removeValue()
            
        }
        
    }
    
    public init(user: Users, lastMessage: Message ,idRoom : String ) {
        self.user = user
        self.lastMessage = lastMessage
        self.idRoom = idRoom
    }
}
