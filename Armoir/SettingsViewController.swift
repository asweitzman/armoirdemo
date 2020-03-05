//
//  SettingsViewController.swift
//  Armoir
//
//  Created by Rachel Hyon on 12/6/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var saveChanges: UIButton!
    
    @IBOutlet weak var inviteFriends: UIButton!
    
    @IBOutlet weak var changeUsername: UIButton!
    
    @IBOutlet weak var changePicture: UIButton!
    
    func makeButtonsRound(){
        self.inviteFriends.layer.cornerRadius = 7
        self.inviteFriends.clipsToBounds = true
        self.changeUsername.clipsToBounds = true
        self.saveChanges.layer.cornerRadius = 7
        self.saveChanges.clipsToBounds = true
        
        self.changePicture.layer.cornerRadius = 7
        
        self.changeUsername.layer.cornerRadius = 7
        self.changePicture.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.image = UIImage(named: "images/rhea.png")
        if let url = currentUser?.photoURL {
            let data = try? Data(contentsOf: url)
            let image = try? UIImage(data: data!)
            self.profileImage.image = image as! UIImage;
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        makeButtonsRound()

        // Do any additional setup after loading the view.
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
