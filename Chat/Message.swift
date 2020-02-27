//
//  Message.swift
//  ChatFramework
//
//  Created by TRIMECH
//  Copyright © 2018 macbook pro. All rights reserved.

// This class is the most important class in Framework, it is responsible for sending and receiving messages//



import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

@objc public class Message: NSObject {
    ////////////////////////////////////////////////////////////////////////////////////////////////
                                           //MARK: Properties//
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public var owner: MessageOwner
    public var type: MessageType
    public var content: Any
    public var timestamp: Int
    public var isRead: Bool
    public var toID: String?
    public var fromID: String?
    ////////////////////////////////////////////////////////////////////////////////////////////////
                                            //MARK: Methods//
    ////////////////////////////////////////////////////////////////////////////////////////////////
    /**
This method allows us to send and crypt messages received
     /// - Parameters:
     -  idRoom: The id of conversation(String).
     -  message: The received Message(Message).
     -  toID: The receiver ID(String)
     //Returns Boolean value
     */
    public class func send(idRoom : String,
                     message: Message,
                     toID: String,
                     completion: @escaping (Bool) -> Swift.Void)  {
        
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            switch message.type {
            case .location:
                let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                let encrypted = AES256CBC.encryptString(message.content as! String, password: password)
                let values = ["type": "location", "content": encrypted as Any, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                Message.uploadMessage(withValues: values, IdRoom:idRoom, toID: toID, completion: { (status) in
                    completion(status)
                })
            case .text:
                let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                let encrypted = AES256CBC.encryptString(message.content as! String, password: password)
                let values = ["type": "text", "content": encrypted as Any , "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                Message.uploadMessage(withValues: values,IdRoom:idRoom, toID: toID, completion: { (status) in
                    completion(status)
                })
            case .photo:
                let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                let encrypted = AES256CBC.encryptString(message.content as! String, password: password)
                let values = ["type": "photo", "content": encrypted as Any, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                Message.uploadMessage(withValues: values, IdRoom:idRoom,toID: toID, completion: { (status) in
                    completion(status)
                })
            case .video:
                
                // File located on disk
                let localFile = message.content as! URL
                
                // Create a reference to the file you want to upload
                _ = UUID().uuidString + String(message.timestamp)
                let riversRef = Storage.storage().reference().child("messageVideos")
                
                // Upload the file to the path "images/rivers.jpg"
                _ = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
                    if error == nil {
                        let text = metadata?.downloadURL()?.absoluteString
                        let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                        let encrypted = AES256CBC.encryptString(text! , password: password)
                        let values = ["type": "video", "content": encrypted , "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                        Message.uploadMessage(withValues: values, IdRoom:idRoom,toID: toID, completion: { (status) in
                            completion(status)
                        })
                    }
                }
                
            }}}
    /**
     This method allows to framework: stock message in database
     /// - Parameters:
     -  message: The received Message(Message).
     - toID: The receiver ID(String)
     //Returns : Boolean value
     */

     public class func uploadMessage(withValues: [String: Any],
                              IdRoom:String ,
                              toID: String,
                              completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            Database.database().reference().child("conversations").child(currentUserID).child(IdRoom).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    Database.database().reference().child("chats").child(IdRoom).childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        Database.database().reference().child("conversations").child(toID).child(IdRoom).setValue(withValues)
                        Database.database().reference().child("conversations").child(currentUserID).child(IdRoom).setValue(withValues)
                        
                    })
                }
                else {
                    Database.database().reference().child("chats").child(IdRoom).childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        Database.database().reference().child("conversations").child(toID).child(IdRoom).setValue(withValues)
                        Database.database().reference().child("conversations").child(currentUserID).child(IdRoom).setValue(withValues)
                        
                        completion(true)
                    })
                }
            })
        }
    }
    /**
     This method allows us to download message of type video
     /// - Parameters:
     -  message: The received Message(Message).
     //Returns : Data value
     */

   public class func downloadVideo(message: Message,
                             completion: @escaping (Data) -> Swift.Void)  {
        if message.type == .video {
            let videoLink = message.content
            let videoURL = URL.init(string: videoLink as! String)
            URLSession.shared.dataTask(with: videoURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    completion(data!)
                }
            }).resume()
        }
    }
    
    /**
     This method allows us to download and decrypt messages
     /// - Parameters:
     -  idRoom: The id of conversation(String).
     //Returns : Message
     */
    public class func downloadAllMessages(IdRoom: String,
                                    completion: @escaping (Message) -> Swift.Void) {
        let currentUserID = Auth.auth().currentUser?.uid
        
        // var kPagination: Int?
        //  let kPagination = (kPagination) + 1
        Database.database().reference().child("chats").child(IdRoom).observe(.childAdded, with: { (snap) in
            if snap.exists() {
                DispatchQueue.main.async {
                    let receivedMessage = snap.value as! NSDictionary
                    //let messageDict : NSDictionary = receivedMessage.object(forKey: key) as! NSDictionary
                    //let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
                    // let decrypted = AES256CBC.decryptString((receivedMessage["content"] as? String)!, password: password)
                    let content = receivedMessage["content"] as? String
                    let fromID = receivedMessage["fromID"] as? String
                    let timestamp = receivedMessage["timestamp"] as! Int
                    let messageType = receivedMessage["type"] as? String
                    var type = MessageType.text
                    if messageType == "photo" {
                        type = .photo
                    } else if messageType == "video" {
                        type = .video
                        let videoLink = content as! String
                        let videoURL = URL.init(string: videoLink)
                        URLSession.shared.dataTask(with: videoURL!, completionHandler: { (data, response, error) in
                            if error == nil {
                                
                            }
                        }).resume()
                    }
                    else if messageType == "location" {
                        type = .location
                    }
                    var message : Message
                    let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
                    let decrypted = AES256CBC.decryptString( content! , password: password)
                    if fromID == currentUserID {
                        message = Message.init(type: type, content: decrypted as Any , owner: .sender, timestamp: timestamp, isRead: true)
                        completion(message)
                        
                    } else {
                        message = Message.init(type: type, content: decrypted as Any, owner:.receiver , timestamp: timestamp, isRead: true)
                        completion(message)
                        
                    } } }  })
        
    }
   
   public init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
