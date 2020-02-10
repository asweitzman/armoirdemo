//
//  ChatConstants.swift
//  Armoir
//
//  Created by Ellen Roper on 2/9/20.
//  Copyright © 2020 CS147. All rights reserved.
//

struct Constants {

  struct NotificationKeys {
    static let SignedIn = "onSignInCompleted"
  }

  struct Segues {
    static let SignInToFp = "SignInToFP"
    static let FpToSignIn = "FPToSignIn"
  }

  struct MessageFields {
    static let name = "name"
    static let text = "text"
    static let photoURL = "photoUrl"
    static let imageURL = "imageUrl"
  }
}
