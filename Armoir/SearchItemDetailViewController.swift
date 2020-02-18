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
    
    func addItem(itemID: Int) {
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        let item = ["item_id": chosenItem.item_id, "name": chosenItem.name, "owner": chosenItem.owner, "borrowed": true, "borrowed_by": user?.uid, "image": chosenItem.image, "color": "", "size": chosenItem.size, "price": chosenItem.price, "category": chosenItem.category, "distance": 1.2] as [String : Any]
        ref.child("users/\(user!.uid)/borrowed/\(itemID)/").setValue(item)
    }
    
    @IBAction func borrowItemButton(_ sender: Any) {
        
        var ref = Database.database().reference()
        var currUser = Auth.auth().currentUser
        ref.child("items").child(String(currItem)).child("borrowed").setValue(true)
    ref.child("items").child(String(currItem)).child("borrowed_by").setValue(currentUser?.uid)
        var borrowedRef = ref.child("users").child(currentUser!.uid).child("borrowed")
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
        
 /*
        //1. find index of item in all_users array
        var i = 0;
        var it_i = 0;
        var found = false;
        for u in all_users {
            if (!found) {
                it_i = 0
            }
            for it in u.closet {
                if (it.item_id == chosenItem.item_id) {
                    found = true
                }
                if (!found) {
                    it_i += 1
                }
            }
            if (!found) {
                i += 1
            }
        }
        
        //2. use the index to change the actual element in all users
        //print (all_users[i]) //testing before
        all_users[i].closet[it_i].borrowed = true
        all_users[i].closet[it_i].borrowed_by = currUser.user_ID
        
        Analytics.logEvent("item_borrowed", parameters: ["currUserID": currUser.user_ID])
        
        //3. find index of currUser in all_users array
        var b = 0;
        var found_b = false;
        for u in all_users {
            if (u.user_ID == currUser.user_ID) {
                found_b = true
            }
            if (!found_b) {
                b += 1
            }
        }
        
        //4. use the index to change the actual element in all users
        var temp = all_users[b].borrowed
        temp.append(all_users[i].closet[it_i])
        all_users[b].borrowed = temp
        currUser.borrowed = temp
        
        print(all_users[b])
        print("DIFF")
        print(all_users[i])
        
        //encode to json
        var text = "" //just a text
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(all_users)
            text = String(data: data, encoding: .utf8)!
            //longJsonData = String(data: data, encoding: .utf8)!
            print("DONE ENCODING")
            //print(String(data: data, encoding: .utf8)!)
        }
        catch {
            print("array didn't work");
        }
        
        //save to json file
        do {
            try text.write(toFile: fullDestPathString, atomically: true, encoding: String.Encoding.utf8)
            print(fullDestPathString)
        }
        catch {
            print(error)
        }
        
//        let path = "search" //this is the file. we will write to and read from it
//        print("continuing");
//
//        if let fileURL = Bundle.main.url(forResource: path, withExtension: "json") {
//            do {
//                try text.write(to: fileURL, atomically: false, encoding: .utf8)
//                print("tried to write")
//            }
//            catch {
//                print ("oh no");
//            }
//        }
        let alert = UIAlertController(title: "You borrowed an item! Go check out your closet.", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            _ = self.navigationController?.popViewControllers(viewsToPop: 1)
            /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SearchItemDetailVC") as! SearchItemDetailViewController
            self.present(nextViewController, animated:true, completion:nil)*/
        }))
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        

 */

    }
    

        override func viewDidLoad() {
            super.viewDidLoad()
            let currentUser = Auth.auth().currentUser
            print(chosenItem)
            itemSize.text = "Size: " + chosenItem.size
            itemDescrip.text = chosenItem.size
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
