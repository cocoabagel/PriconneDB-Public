//
//  User.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/28.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
