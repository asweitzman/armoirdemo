//
//  BorrowedItemDetailViewController.swift
//  Armoir
//
//  Created by rhea krtr on 06/12/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import Firebase

class BorrowedItemDetailViewController: UIViewController {
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var sizeDetail: UILabel!
    @IBOutlet weak var priceDetail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescrip: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    let imageCache = NSCache<NSString, UIImage>()
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        let item = String(currItem)
        let ref = Database.database().reference().child("items").child(item)
        ref.observe(.value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            let chat = snapshotValue["currentChat"] as! String
            currChat = chat
            currItemID = currItem
            let chatRef = Database.database().reference().child("chats").child(currChat)
            chatRef.observe(.value) { (snapshot: DataSnapshot!) in
                let snapshotValue = snapshot.value as! [String : AnyObject]
                currReceiver = snapshotValue["receiver"] as! String
            }
            print("whatwhat " + currChat)
            self.performSegue(withIdentifier: "toChatsSegue", sender: self)
        }
    }
    
    @IBAction func reminderButton(_ sender: UIButton) {
        let chatsDb = Database.database().reference().child("chats")
        let itemref = Database.database().reference().child("items").child(String(currItem))
        itemref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
           // let receiverName = snapshotValue["owner"]
            //let item_name = snapshotValue["name"] as! String
            let chat = snapshotValue["currentChat"] as! String
            let reminderMessage = "This item is due soon!"
            // Get the Unix timestamp
            let timestamp = NSDate().timeIntervalSince1970
            let messageID = self.randomString(length: 20)
            let chatMessageDict = ["senderName": Auth.auth().currentUser?.displayName, "content" : reminderMessage, "timestamp": timestamp, "senderHash": Auth.auth().currentUser!.uid, "messageID" : messageID] as [String : Any]
            chatsDb.child(chat).child("messages").child(messageID).setValue(chatMessageDict)
        }
        let alert = UIAlertController(title: "Reminder sent!", message: "", preferredStyle: .alert)

       
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: false) {
                
            }
        }))
        
        self.present(alert, animated: true)
        sender.isEnabled = false
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderButton.isHidden = true

        messageButton.isHidden = true
        
        if (status_lending) {
            currArray = lentArray
            messageButton.isHidden = false
        } else if (status_closet) {
            currArray = closetArray
        }
        
        
        for i in currArray {
            if (i.item_id == currItem) {
                priceDetail.text = "$" + String(i.price) + "/day";
                sizeDetail.text = i.size;
                //distanceText.text = i.distance;
                //let imageI = UIImage(named: i.image);
                
                let imageRef = storageRef.child("images/" + String(i.image))
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("image url error")
                    } else {
                        self.itemImage.image = self.downloadImage(imageName: String(i.image), url: url!)
                    }
                }
                
//                let imgURL = i.image
//                if (ImageRetriever().fileIsURL(fileName: imgURL)) {
//                    self.itemImage.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
//                } else {
//                    self.itemImage.image = UIImage(named: i.image);
//                }
                
                
                //self.itemImage.image = imageI;
                self.itemImage.clipsToBounds = true;
                itemDescrip.text = i.name;
                var userID = i.owner;
                if (status_lending) {
                    userID = String(i.borrowed_by);
                    //TODO add not hardcoded here. easy.
                    var currItemId = String(currItem)
                    let ref = Database.database().reference().child("items").child(currItemId)
                    ref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                        let snapshotValue = snapshot.value as! [String: AnyObject]
                        let borrowerHash = snapshotValue["borrowed_by"]
                        let userref = Database.database().reference().child("users").child(borrowerHash as! String)
                        userref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                            if let snapVal = snapshot.value as? [String: Any] {
                                let name = snapVal["display_name"] as? String
                                self.distanceText.text = "Borrowed by " + name!
                            }
                        }
                    }
                    reminderButton.isHidden = false;
                } else {
                    distanceText.text = "Not borrowed";
                    reminderButton.isHidden = true;
                }
                var user: a_User;
                userName.text = "Owned by you"
                
                for stru in all_users {
                    if String(stru.user_ID) == userID {
                        user = stru;
                        var image = UIImage(named: user.profPic);
                        if (status_lending) {
////                            userName.text = user.owner;
//
//                            userName.text = "Ellen Roper"
//                            userName.isHidden = false
                        } else {
                            userName.text = "Owned by you";
                            if let url = currentUser?.photoURL {
                                let data = try? Data(contentsOf: url)
                                image = try! UIImage(data: data!)
                                self.profPic.image = image as! UIImage;
                            }
                        }
                        
                        self.profPic.image = image;
                        self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
                        self.profPic.clipsToBounds = true;
                    }
                }
                
                
                
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func downloadImage(imageName: String, url: URL) -> UIImage{
        let imageRef = storageRef.child("images/" + String(imageName))
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
              return cachedImage
        }
        let data = try? Data(contentsOf: url)
        let image = UIImage(data: data!)
        let thumb1 = image?.resized(By: 0.2)
        self.imageCache.setObject(thumb1!, forKey: url.absoluteString as NSString)
        return thumb1 as! UIImage;
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
