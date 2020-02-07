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

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//            if user != nil {
//                self.performSegue(withIdentifier: "toBegin", sender: self)
//            }
//        }
        let loginButton = FBLoginButton()
        //loginButton.delegate = self as! LoginButtonDelegate
        loginButton.center = view.center
        view.addSubview(loginButton)
        //let loginButton = FBLoginButton(readPermissions: [ .publicProfile ])
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickedFB(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toBegin", sender: self)
            return
        }
        print("here")
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
