//
//  File.swift
//  ChatFramework
//
//  Created by macbook pro on 22/02/2018.
//  Copyright © 2018 macbook pro. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseRemoteConfig

public func testFramework()  -> Bool {
  
    FirebaseApp.configure()
    Database.database().isPersistenceEnabled = true

  /*  Users.registerUserwithEmail(name: "userrrr.name", email: "nn@gmail.com", password: "PasswordTextField.text!", sexe: "userrrr.sexe", birthDate: "userrrr.birthDate", profilePic: "userrrr.profilpicString" , completion: { (user) in
        
       
    })*/
    return (true)

}
/*public func  registerUserwithEmail(withName: String, email: String, password: String,sexe: String, birthDate: String, profilePic: String) {
    FirebaseApp.configure()

    var numCompte: Int = 0
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
        if error == nil {
            
            
            user?.sendEmailVerification{ (error) in
                if let error = error{
                    
                    print("your mail invalid")
                }
            }}})} */


public class testClass {
    public init(){

    }
    public func testmethode() {
        print("testclass methode")
    }

}

