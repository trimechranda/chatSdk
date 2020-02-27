//
//  User.swift
//  ChatFramework
//
//  Created by TRIMECH on 20/04/2018.
//  Copyright © 2018 macbook pro. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

 @objc public class Users : NSObject{
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                               //MARK: Properties
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public let name: String
    public let id: String
    public let birthDate: String
    public let sexe :String
    public let profilpicString :String
    public var profilePic: UIImage?
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              //MARK: Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
//  Register user with email
///
/// - Parameters:
///   - withName: the name of user (String)
///   - email: the email of user (String : with format xxx@xx.xx) (String)
///   - password: the password contains lettrs and numbers (String)
///   - sexe: man or women (String)
///   - birthDate: the birth date (String)
///   - profilePic: uimage
///   - completion: bool
  public class func registerUserwithEmail(name: String,
                                  email: String,
                                  password: String,
                                  sexe: String,
                                  birthDate: String,
                                  profilePic: String,
                                  completion: @escaping (Users) -> Swift.Void) {
    
    Auth.auth().createUser(withEmail: email,
                           password: password,
                           completion: { (user, error) in
                       
                            let userUID = user?.uid
                            if error == nil {
                                
                                user?.sendEmailVerification{ (error) in
                                
                                    if error != nil{
                                        print("your mail invalid")
                                    }
                                    else{
                                        Database.database().reference().child("users").observe(.value, with: { (snapshot: DataSnapshot!) in
                                            let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
                                            let profilepicString = AES256CBC.encryptString(profilePic, password: password)!
                                            let values = ["name": name, "email": email,"sexe": sexe,"birthDate": birthDate,"profilePicLink": profilepicString] as [String : Any];
                                            let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
                                          
                                            Database.database().reference().child("users").child(userUID!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                                                
                                                
                                                if errr == nil {
                                                    let values = ["idphone": UUIDValue, "codeValidation": "123456"]; Database.database().reference().child("users").child(userUID!).child("devicesID").child("id0").setValue( values)
                                                    let user =  Users.init( name: name, id: (userUID)!, birthDate: birthDate, sexe: sexe, profilpicString: profilePic)
                                                   
                                             
                                                    completion(user)
                                                    
                                                }  })
                                        })}}
                            }})
}

/// Send a verification code to the user's phone
///
/// - Parameters:
///   - phoneNumber: the phone number of user
///   - completion: String : return verification ID
  public class func VerificationUserwithPhone(phoneNumber: String,
                                      completion: @escaping (String) -> Swift.Void){
    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
        DispatchQueue.main.async {
            if error != nil {
                return
            }
            else{
                UserDefaults.standard.synchronize()
                
            }
            completion (verificationID!)
            
        }
    }
}
/// Register user with phone number
///
/// - Parameters:
///   - verificationCode: the id (for sms)
///   - verificationID: verification id (from func registerUserwithPhone)
///   - withName: Name of user
///   - PhoneNumber: phone number of user
///   - password: password
///   - sexe: men or women
///   - birthDate: string
///   - profilePic: uimage
///   - completion: return bool

  public class func registerUserwithPhone( verificationCode: String,
                                   verificationID: String,
                                   withName: String,
                                   PhoneNumber: String,
                                   password: String,
                                   sexe: String,
                                   birthDate: String,
                                   profilePic: String,
                                   completion: @escaping (Bool) -> Swift.Void) {
    
    let credential = PhoneAuthProvider.provider().credential( withVerificationID: verificationID, verificationCode: verificationCode)
    Auth.auth().signIn(with: credential) { (user, error) in
        if error != nil {
            print ("user is not signn")
            completion(false)
            
            return
        }
        
        
        print ("user is signn")
        if(!withName.isEmpty){
            /* Database.database().reference().child("users").observe(.value, with: { (snapshot: DataSnapshot!) in
             print("Got snapshot");
             print(snapshot.childrenCount)
             var numCompte: Int = 0
             
             numCompte = Int(snapshot.childrenCount)*/
            let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
            let profilepicString = AES256CBC.encryptString(profilePic, password: password)!
            let values = ["name": withName, "PhoneNumber": PhoneNumber,"sexe": sexe,"birthDate": birthDate,"profilePicLink": profilepicString] as [String : Any];                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                if errr == nil {
                }
            })}
        else{
            print ("userrrrrr is signn")
            
        }
        completion(true)
        
    }
}
///
///Authentification with email
///
    /// - Parameters:

    ///   - Email: Email of user
    ///   - password: password
    ///   - completion: return bool values
  public class func AuthentificationUserwithMail(Email: String,
                                           password: String,
                                           completion: @escaping (Bool,Bool) -> Swift.Void) {
    //var perso : User?
    
    Auth.auth().signIn(withEmail: Email, password: password, completion: { (user, error) in
        
        if error != nil {
            print("verifier votre mail ou mot de passe")
            completion(false,false)
        }
        else if user != nil {
            
            let userID : String = (Auth.auth().currentUser?.uid)!
            let UUIDValue :String = UIDevice.current.identifierForVendor!.uuidString
            Database.database().reference().child("users").child(userID).child("devicesID").observe(.value, with: { (snapshot) in
                let data = snapshot.value as? NSDictionary
                
                let values = data?.allValues
                var dataff : NSDictionary?
                let idCount = data?.allKeys.count
                var allIdPhone : [String] = []
                for i in 0 ... (values?.count)!-1 {
                    dataff = values![i] as? NSDictionary
                    let idphoneString : String = dataff!["idphone"] as! String
                    allIdPhone.append(idphoneString)
                    
                }
                
                if (allIdPhone.contains(UUIDValue)) {
                    print("ooook")
                    
                    completion(true,true)
                }
                else{
                    let idphone =  "id\((idCount!))"
                    let values = ["idphone": UUIDValue, "codeValidation": "123456"]; Database.database().reference().child("users").child((user?.uid)!).child("devicesID").child(idphone).setValue(values)
                    completion(true,false)
                }
            })
        }})
}
///
///Authentification with phone number
    /// - Parameters:
    
    ///   - verificationCode: the code receiver in SMS
    ///   - verificationID: password
    ///   - completion: return bool value
///
  public class func AuthentificationUserwithPhone( verificationCode: String,
                                           verificationID: String,
                                           completion: @escaping (Bool) -> Swift.Void) {
    
    let credential = PhoneAuthProvider.provider().credential( withVerificationID: verificationID, verificationCode: verificationCode)
    Auth.auth().signIn(with: credential) { (user, error) in
        if error != nil {
            print ("user is not signn")
            completion(false)
            
        }
        
        print ("user is signn")
        
        completion(true)
        
    }
}



///
///Get the credentiels of user

    /// - Parameters:
    
    ///   - forUserID: id of user
    ///   - completion: return user
  public class func GetInfoUser(forUserID: String,
                        completion: @escaping (Users) -> Swift.Void) {
  Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
       // print(snapshot.value)
        let data = snapshot.value as? NSDictionary
        let name = data!["name"]!
        let birthDate = data!["birthDate"]!
        let sexe = data!["sexe"]!
        let profilpicString = data!["profilePicLink"]!
        let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
        let decrypted = AES256CBC.decryptString(profilpicString as! String, password: password)
        
        let user = Users.init(name: name as! String, id: forUserID,birthDate: birthDate as! String,sexe:sexe as! String,profilpicString: decrypted! )
    print("converssationnnnn")
    print(user)
        completion(user)
        
    })
}
///
///Log out
///
  public class func logOutUser() {
    let firebaseAuth = Auth.auth()
    do {
        try firebaseAuth.signOut()
    }
    catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
    }}

///
///update the parameters of user
///
    /// - Parameters:
    
    ///   - name: Name of user
    ///   - email: phone number of user
    ///   - sexe: men or women
    ///   - birthDate: string
    ///   - profilePic: uimage
    ///   - completion: return bool
  public class func updateUser(name: String,
                       email: String,
                       sexe: String,
                       birthDate: String,
                       profilePic: String,
                       completion: @escaping (Bool) -> Swift.Void) {
    if let id = Auth.auth().currentUser?.uid {
        let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
        let encrypted = AES256CBC.encryptString(profilePic, password: password)
        let values = ["name": name, "email": email,"sexe": sexe,"birthDate": birthDate,"profilePicLink": encrypted as Any] as [String : Any];                        Database.database().reference().child("users").child(id).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }})}
    else {
        completion(false)
    }
}
///
///Reset password
///
    /// - Parameters:
    ///   - email: phone number of user
    ///   - completion: return boolean value
  public class func ResetPassword(email: String,
                         completion: @escaping (Bool) -> Swift.Void) {
    
    Auth.auth().sendPasswordReset(withEmail: email) { error in
        
        if error != nil {
            completion(false)
        }
        else{
            
            completion(true)
        }
    }
}
///
///get the code when authentificate with new device
///
    /// - Parameters:
    
    ///   - foruserID: id of user
    ///   - completion: return string value
 public class func getCode (foruserID: String,
                     completion: @escaping (String) -> Void){
    Database.database().reference().child("users").child((foruserID)).child("devicesID").child("id0").child("codeValidation").observeSingleEvent(of: .value, with: { (snapshot) in
        let codeValidation = "123456"
        completion(codeValidation)
        
    })
}

 
    /// Update the credentials of user
    ///
    /// - Parameters:
    ///   - name: name user
    ///   - email: email user
    ///   - sexe: sexe user
    ///   - birthDate: birthdate user
    ///   - profilePic: profile picture user
    ///   - numCompte: numero compte user
    ///   - completion: return bool value
    public class func updateUser(name: String,
                          email: String,
                          sexe: String,
                          birthDate: String,
                          profilePic: String,
                          numCompte: Int,
                          completion: @escaping (Bool) -> Void) {
        if let id = Auth.auth().currentUser?.uid {
            let password = "azdrezcldkdk123dkdbnchpeqwxdplke"  // returns random 32 char string
            let encrypted = AES256CBC.encryptString(profilePic, password: password)
            let values = ["name": name, "email": email,"sexe": sexe,"birthDate": birthDate,"profilePicLink": encrypted as Any,"numCompte": numCompte] as [String : Any];                        Database.database().reference().child("users").child(id).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                if errr == nil {
                    completion(true)
                }})}
        else {
            completion(false)
        }
    }
    
    // Show list of ids friends
    ///
    /// - Parameters:
    ///   - completion: return array of string
    public class func ShowListFriendsID(completion: @escaping ([String]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("friends").child(currentUserID).queryOrdered(byChild: "isFriend").queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as? NSDictionary
                    // let name = data!["key"]!
                    let keys = data?.allKeys as! [String]
                    completion(keys)
                }})
            
        }
    }
    // Show list contact
    ///
    /// - Parameters:
    ///   - completion: return array of user
    public class func ShowListContact() {
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as? NSDictionary
                    // idroom = snapshot.key
                    let sexe = data?.value(forKey: "sexe") as! String
                    let name = data?.value(forKey: "name") as! String
                    // let name = data!["key"]!
                    //  completion()
                }}) }
    // Show list of invitations receiver
    ///
    /// - Parameters:
    ///   - completion: return array of string
    public class func ShowListInvitation(completion: @escaping ([String]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("friends").child(currentUserID).queryOrdered(byChild: "isFriend").queryEqual(toValue: false).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as? NSDictionary
                    // let name = data!["key"]!
                    let keys = data?.allKeys as! [String]
                    completion(keys)
                }})
            
        }
    }
    // Send invitation
    ///
    /// - Parameters:
    /// - IDFriend : ID of friend
    ///   - completion: return boolean value
    public class func SendInvitation(IDFriend : String,
                              completion: @escaping (Bool) -> Swift.Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            let values = ["isFriend": false]
            Database.database().reference().child("friends").child(IDFriend).child(currentUserID).setValue(values, withCompletionBlock: { (errr, _) in
                if errr == nil {
                    completion(true)
                }
                else {
                    completion(false)
                }})
        }}
    // Refus invitation
    ///
    /// - Parameters:
    /// - IDFriend : ID of friend
    
    public class func RefusInvitation(IDFriend : String) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("friends").child(currentUserID).child(IDFriend).removeValue()
        }}
    // Accept invitation
    ///
    /// - Parameters:
    /// - IDFriend : ID of friend
    ///   - completion: return boolean value
    public class func AcceptInvitation(IDFriend : String,
                                 completion: @escaping (Bool) -> Swift.Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            let IdRoom = currentUserID+IDFriend
            let values = ["isFriend": true]
            
            Database.database().reference().child("friends").child(IDFriend).child(currentUserID).setValue(values); Database.database().reference().child("friends").child(currentUserID).child(IDFriend).setValue(values, withCompletionBlock: { (errr, _) in
                if errr == nil {
                    let password = "azdrezcldkdk123dkdbnchpeqwxdplke"
                    let encrypted = AES256CBC.encryptString("Hello!", password: password)
                    let values = ["type": "text", "content": encrypted as Any, "fromID": currentUserID, "toID": IDFriend, "timestamp": Int(Date().timeIntervalSince1970), "isRead": false] as [String : Any]
                    Message.uploadMessage(withValues: values, IdRoom:IdRoom, toID: IDFriend, completion: { (status) in
                        completion(status)
                    })
                    completion(true)
                }
                else {
                    completion(false)
                }})
        }}
    // Delete invitation
    ///
    /// - Parameters:
    /// - IDFriend : ID of friend
    public class func DeleteFriend(IDFriend : String) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("friends").child(currentUserID).child(IDFriend).removeValue()
        }}
    
 public init(name: String, id: String, birthDate: String,sexe:String,profilpicString: String) {
    self.name = name
    self.id = id
    self.birthDate = birthDate
    self.sexe = sexe
    self.profilpicString = profilpicString
}
}
