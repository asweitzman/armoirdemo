//
//  LentItemViewController.swift
//  Armoir
//
//  Created by rhea krtr on 06/12/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import Firebase

class LentItemViewController: UIViewController {

    @IBOutlet weak var sizeDetail: UILabel!
    @IBOutlet weak var daysLeft: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var distDisplay: UILabel!
    @IBOutlet weak var priceDisplay: UILabel!
    @IBOutlet weak var imgDisplay: UIImageView!
    @IBOutlet weak var itemDescrip: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBAction func messageButton(_ sender: Any) {
        msgButtonHelper()
       // self.performSegue(withIdentifier: "toChatsSegue", sender: self)
    }
    
    func msgButtonHelper() {
        let item = String(currItem)
        let ref = Database.database().reference().child("items").child(item)
        ref.observe(.value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            let chat = snapshotValue["currentChat"] as! String
            currChat = chat
            print("what" + currChat)
            //self.performSegue(withIdentifier: "toChatsSegue", sender: self)
            //let snapVal = snapshot.value as! [String : AnyObject]
           // let test = snapVal.keys
           // print(test)
            //let res = test.first
            //print(res)
            //currChat = res!
            self.performSegue(withIdentifier: "toChatsSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daysLeft.text = "10 days left";
        for i in currFirebaseArray {
            if (i.item_id == currItem) {
                priceDisplay.text = "$" + String(i.price) + "/day";
                //distDisplay.text = i.distance;
                sizeDetail.text = i.size;
                let imageRef = storageRef.child("images/" + String(i.image))
                imageRef.downloadURL { url, error in
                  if let error = error {
                    print("image download error")
                  } else {
                    let data = try? Data(contentsOf: url!)
                    let image = try? UIImage(data: data!)
                    self.imgDisplay.image = image as! UIImage
                    self.imgDisplay.clipsToBounds = true;
                  }
                }
//                let imageI = UIImage(named: i.image);
//                self.imgDisplay.image = imageI;
//                self.imgDisplay.clipsToBounds = true;
                itemDescrip.text = i.name;
                distDisplay.text = String(i.distance) + " mi"
                //code to read username from the database
                let ref = Database.database().reference().child("users")
                ref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                    let snapshotValue = snapshot.value as! [String : AnyObject]
                    let ownerVal = snapshotValue[i.owner] as! [String: AnyObject]
                    let usernameString = ownerVal["display_name"] as! String
                    self.userName.text = usernameString
                    let imageUrl = ownerVal["profPic"] as! String
                    let profRef = storageRef.child("images/\(imageUrl)")
                    profRef.downloadURL { url, error in
                      if let error = error {
                        print("image download error")
                      } else {
                        let data = try? Data(contentsOf: url!)
                        let image = try? UIImage(data: data!)
                        self.profPic.image = image as! UIImage;
                      }
                    }
                }

                /*var myStructArray:[a_User] = [];
                 do {
                 try myStructArray = JSONDecoder().decode([a_User].self, from: json);
                 }
                 catch {
                 print("array didn't work");
                 }
                 for stru in myStructArray { */
//                for stru in all_users {
//                    if stru.user_ID == userID {
//                        user = stru;
//                        userName.text = user.owner;
//                        let image = UIImage(named: user.profPic);
//                        self.profPic.image = image;
//                        self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
//                        self.profPic.clipsToBounds = true;
//                    }
//                }
                
                
                
            }
        }
        

        
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
