//
//  SearchItemDetailViewController.swift
//  Armoir
//
//  Created by alex weitzman on 12/6/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import Firebase

class SearchItemDetailViewController: UIViewController {
        
        @IBOutlet weak var priceDetail: UILabel!
        @IBOutlet weak var userName: UILabel!
        @IBOutlet weak var profPic: UIImageView!
        @IBOutlet weak var distanceText: UILabel!
        @IBOutlet weak var itemImage: UIImageView!
        @IBOutlet weak var itemDescrip: UILabel!
    @IBOutlet weak var itemSize: UILabel!
    let chatMessageDB = Database.database().reference().child("Messages")
    let rootDB = Database.database().reference()
    let chatsDb = Database.database().reference().child("chats")
    let usersDB = Database.database().reference().child("users")
    var owner = ""
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func addItem(itemID: Int) {
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        let item = ["item_id": chosenItem.item_id, "name": chosenItem.name, "owner": chosenItem.owner, "borrowed": true, "borrowed_by": user?.uid, "image": chosenItem.image, "color": "", "size": chosenItem.size, "price": chosenItem.price, "category": chosenItem.category, "distance": chosenItem.distance] as [String : Any]
        ref.child("users/\(user!.uid)/borrowed/\(itemID)/").setValue(item)
    }
    
    func addNewChat(chatID: String) {
        let itemref = Database.database().reference().child("items").child(String(currItem))
        itemref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            let item_id = snapshotValue["item_id"]
            let status = snapshotValue["borrowed"]
            let sender = currentUser!.uid
            let senderName = currentUser?.displayName
            let receiver = snapshotValue["owner"]
            let chatDict = ["item_id": item_id, "sender" : sender, "senderName" : senderName, "receiver" : receiver, "status": status, "messages": []] as [String: Any]
            self.chatsDb.child(chatID).setValue(chatDict)
        }
    }
    
    func addChatToUser(chatID: String) {
        //adding user chats to user if it doesn't exist
        let senderRef = rootDB.child("users").child(currentUser!.uid)
        let itemref = Database.database().reference().child("items").child(String(currItem))
        //add chat to recipient's chatlist
        itemref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String: AnyObject]
            let receiverHash = snapshotValue["owner"] as! String
            let recipientRef = self.rootDB.child("users").child(receiverHash)
            recipientRef.child("chats").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists(){
                    recipientRef.child("chats").setValue("")
                }
            })
            recipientRef.child("chats").child(chatID).setValue(chatID)
        }
        
        //add chat to sender's chatlist
        senderRef.child("chats").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists(){
                senderRef.child("chats").setValue("")
            }
        })
        //updating user chats to add chatID for reference
        senderRef.child("chats").child(chatID).setValue(chatID)
    }
    
    func addInitialMsg(chatID: String){
        let itemref = Database.database().reference().child("items").child(String(currItem))
        itemref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            let receiverName = snapshotValue["owner"]
            let item_name = snapshotValue["name"] as! String
            itemref.child("currentChat").setValue(chatID)
            let requestMessageString = "Hi, I'd like to borrow your " + item_name
            // Get the Unix timestamp
            let timestamp = NSDate().timeIntervalSince1970
            let messageID = self.randomString(length: 20)
            let chatMessageDict = ["senderName": Auth.auth().currentUser?.displayName, "content" : requestMessageString, "timestamp": timestamp, "senderHash": Auth.auth().currentUser!.uid, "messageID" : messageID] as [String : Any]
            self.chatsDb.child(chatID).child("messages").child(messageID).setValue(chatMessageDict)
        }
    }
    
    
    @IBAction func borrowItemButton(_ sender: Any) {
        let currUser = Auth.auth().currentUser
        //updating items list
        //rootDB.child("items").child(String(currItem)).child("borrowed").setValue(true)
       // rootDB.child("items").child(String(currItem)).child("borrowed_by").setValue(currentUser?.uid)
        let borrowedRef = rootDB.child("users").child(currentUser!.uid).child("borrowed")
        let chatID = randomString(length:20)
        addNewChat(chatID: chatID)
        addChatToUser(chatID: chatID)
        addInitialMsg(chatID: chatID)
        
        let alert = UIAlertController(title: "Sent request to borrow this item! Check your inbox for updates.", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            _ = self.navigationController?.popViewControllers(viewsToPop: 1)}))
        self.present(alert, animated: true)
        let group = DispatchGroup()
        group.enter()
        var itemID = 0
        group.notify(queue: .main) {
            self.addItem(itemID: itemID)
        }
        borrowedRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                itemID = Int(snapshot.childrenCount)
                print("item id 1: " + String(itemID))
                group.leave()
            }
    }
    

        override func viewDidLoad() {
            super.viewDidLoad()
            let currentUser = Auth.auth().currentUser
            itemSize.text = "Size: " + chosenItem.size
            itemDescrip.text = chosenItem.name
            
                let ref = Database.database().reference().child("users")
            ref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                let snapshotValue = snapshot.value as! [String : AnyObject]
                let ownerVal = snapshotValue[chosenItem.owner] as! [String: AnyObject]
                let usernameString = ownerVal["display_name"] as! String
                self.userName.text = usernameString
                self.owner = usernameString
                let imageUrl = ownerVal["profPic"] as! String
                let profRef = storageRef.child("images/\(imageUrl)")
                profRef.downloadURL { url, error in
                  if let error = error {
                    print("image download error")
                  } else {
                    let data = try? Data(contentsOf: url!)
                    let image = try? UIImage(data: data!)
                    self.profPic.image = image as! UIImage
                    self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2
                    self.profPic.clipsToBounds = true
                  }
                }
            }
            
            
            let dist = chosenItem.distance
            let distString = String(format: "%.1f", dist) + " mi."
            distanceText.text = distString
            let imageRef = storageRef.child("images/\(chosenItem.image)/")
            imageRef.downloadURL { url, error in
              if let error = error {
                print("image download error")
              } else {
                let data = try? Data(contentsOf: url!)
                let image = try? UIImage(data: data!)
                self.itemImage.image = image as! UIImage;
              }
            }
            let currPrice = chosenItem.price 
            priceDetail.text = "$" + String(currPrice) + "/day";

            //distanceText.text = String(chosenItem.distance) + " mi"
            itemImage.clipsToBounds = true;
//            for (_,user) in readableJSON {
//                if (currentUser!.uid == chosenItem.owner) {
//                    if let imageStr = user["profPic"].string {
//                        profPic.image = UIImage(named: imageStr)
//                        profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
//                        profPic.clipsToBounds = true;
//                    }
//                    userName.text = currentUser.uid
//                }
//            }
            
            /*for i in currArray {
                if (i.item_id == chosenItem["item_id"].int) {
                    print("success")

                    itemDescrip.text = i.name;
                    var userID = i.owner;
                    if (i.borrowed) {
                        userID = i.borrowed_by;
                        distanceText.text = "Borrowed";
                        
                    } else {
                        distanceText.text = "Currently available";
                    }
                    var user: a_User;
                    var myStructArray:[a_User] = [];
                    do {
                        try myStructArray = JSONDecoder().decode([a_User].self, from: json);
                    }
                    catch {
                        print("array didn't work");
                    }
                    for stru in myStructArray {
                        if stru.user_ID == userID {
                            user = stru;
                            if (i.borrowed) {
                                userName.text = user.name;
                                
                            } else {
                                userName.text = "Owned by you";
                                
                                
                            }

                        }
                    }
                    
                    
                    
                }
            }*/
        }
    
        
}
