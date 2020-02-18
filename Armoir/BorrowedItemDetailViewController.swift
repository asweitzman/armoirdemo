//
//  BorrowedItemDetailViewController.swift
//  Armoir
//
//  Created by rhea krtr on 06/12/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit


class BorrowedItemDetailViewController: UIViewController {
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var sizeDetail: UILabel!
    @IBOutlet weak var priceDetail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescrip: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderButton.isHidden = true
        for i in currArray {
            if (i.item_id == currItem) {
                priceDetail.text = "$" + String(i.price) + "/day";
                sizeDetail.text = i.size;
                //distanceText.text = i.distance;
                //let imageI = UIImage(named: i.image);
                
                let imgURL = i.image
                if (ImageRetriever().fileIsURL(fileName: imgURL)) {
                    self.itemImage.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
                } else {
                    self.itemImage.image = UIImage(named: i.image);
                }
                
                
                //self.itemImage.image = imageI;
                self.itemImage.clipsToBounds = true;
                itemDescrip.text = i.name;
                var userID = i.owner;
                if (i.borrowed) {
                    userID = String(i.borrowed_by);
                    distanceText.text = "Borrowed by";
                    reminderButton.isHidden = false;
                } else {
                    distanceText.text = "Currently available";
                    reminderButton.isHidden = true;
                }
                var user: a_User;
                /*var myStructArray:[a_User] = [];
                do {
                    try myStructArray = JSONDecoder().decode([a_User].self, from: json);
                }
                catch {
                    print("array didn't work");
                }
                for stru in myStructArray { */
                for stru in all_users {
                    if String(stru.user_ID) == userID {
                        user = stru;
                        var image = UIImage(named: user.profPic);
                        if (i.borrowed) {
                            userName.text = user.owner;

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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
