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
    let imageCache = NSCache<NSString, UIImage>()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderButton.isHidden = true
        
        if (status_lending) {
            currArray = lentArray
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
                    distanceText.text = "Borrowed by";
                    reminderButton.isHidden = false;
                } else {
                    distanceText.text = "Not borrowed";
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
                userName.text = "Owned by you"
                
                for stru in all_users {
                    if String(stru.user_ID) == userID {
                        user = stru;
                        var image = UIImage(named: user.profPic);
                        if (status_lending) {
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
