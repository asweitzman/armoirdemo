//
//  FirstViewController.swift
//  Armoir
//
//  Created by alex weitzman on 12/8/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

class FirstViewController: UIViewController {
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let loginButton = FBLoginButton() commenting this out now bc the button isn't used
//        loginButton.center = view.center
//        view.addSubview(loginButton)
          //stuff for Google sign in.
              GIDSignIn.sharedInstance()?.presentingViewController = self
              guard let signIn = GIDSignIn.sharedInstance() else { return }
              if (signIn.hasPreviousSignIn()) {
                signIn.restorePreviousSignIn()
              }
              handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
                if user != nil {
                  self.performSegue(withIdentifier: "toBegin", sender: nil)
                }
              }
          }
          
          deinit {
          if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
          }
          }
    
    @IBAction func clickedFB(_ sender: Any) {
        let ref = Database.database().reference()
        var user = Auth.auth().currentUser
        if user != nil {
            self.performSegue(withIdentifier: "toBegin", sender: self)
            return
        }
        
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
           if let error = error {
               print("Failed to login: \(error.localizedDescription)")
               return
           }
           
            guard let accessToken = AccessToken.current else {
               print("Failed to get access token")
               return
           }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
           
           // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
               if let error = error {
                   print("Login error: \(error.localizedDescription)")
                   let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                   let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                   alertController.addAction(okayAction)
                   self.present(alertController, animated: true, completion: nil)
                   
                   return
               }
                var user = Auth.auth().currentUser
                ref.child("users").child(user!.uid).setValue(["username": user?.displayName, "display_name": user?.displayName])
                self.performSegue(withIdentifier: "toBegin", sender: self)
           })

        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
