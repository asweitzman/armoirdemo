//
//  ClosetViewController.swift
//  Armoir
//
//  Created by alex weitzman on 11/30/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import Foundation

var itemImage: UIImage = UIImage()
var startWithCamera: Bool = Bool()

struct Item: Decodable {
    enum Sizes: String, Decodable {
        case XS, S, M, L, XL
    }
    enum Category: String, Decodable {
        case shirt,pants,skirt,shorts,dress,none
    }
    enum Color: String, Decodable {
        case red, orange, yellow, green, blue, purple, white, black, grey, pink, navy, mixed, none
    }
    
    let item_id: Int
    var name: String
    var owner: Int
    var borrowed: Bool
    var borrowed_by: Int
    var imgURL: String
    var color: String //Color
    var size: String //Sizes
    var price: Double
    var category: String //Category
    
    init(item_id: Int, name: String, owner: Int, borrowed:Bool, borrowed_by: Int, imgURL: String, color: String, size: String, price: Double, category: String) {
        self.item_id = item_id;
        self.name = name;
        self.owner = owner;
        self.borrowed = borrowed;
        self.borrowed_by = borrowed_by;
        self.imgURL="images/" + imgURL;
        self.color = color ;//Color.none;
        self.size = size ;//Sizes.M;
        self.price = price;
        self.category = category ;//Category.none;
        
    }
}



struct a_User {
    let user_ID: Int
    var profPic: String
    var name: String
    var borrowed: [Item]
    var closet: [Item]
    init(user_ID: Int, profPic: String, name: String, borrowed:[Item], closet: [Item]) {
        self.user_ID = user_ID;
        self.profPic = "images/" + profPic;
        self.name = name;
        self.borrowed = borrowed;
        self.closet = closet;
    }
}

extension a_User: Decodable {
    enum userStructKeys: String, CodingKey { // declaring our keys
        case user_ID = "user_ID"
        case profPic = "profPic"
        case name = "owner"
        case borrowed = "borrowed"
        case closet = "closet"
    }
    
    enum itemStructKeys: String, CodingKey { // declaring our keys
        case item_id = "item_id";
        case name = "name";
        case owner = "owner";
        case borrowed = "borrowed";
        case borrowed_by = "borrowed_by";
        case imgURL="image";
        case color = "color_tag";
        case size = "size";
        case price = "price";
        case category = "category";
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: userStructKeys.self) // defining our (keyed) container
        let user_ID: Int = try container.decode(Int.self, forKey: .user_ID) // extracting the data
        let profPic: String = try container.decode(String.self, forKey: .profPic) // extracting the data
        let name: String = try container.decode(String.self, forKey: .name) // extracting the data
        var borrowed_array = try container.nestedUnkeyedContainer(forKey: userStructKeys.borrowed);
        var borrowed: [Item] = [];
        while (!borrowed_array.isAtEnd) {
            let item_container = try borrowed_array.nestedContainer(keyedBy: itemStructKeys.self)
            let i_name: String = try item_container.decode(String.self, forKey: itemStructKeys.name)
            let item_id: Int = try item_container.decode(Int.self, forKey: itemStructKeys.item_id) // extracting the data
            let owner: Int = try item_container.decode(Int.self, forKey: itemStructKeys.owner)
            let borrowed_b: Bool = try item_container.decode(Bool.self, forKey: itemStructKeys.borrowed)
            let borrowed_by: Int = try item_container.decode(Int.self, forKey: itemStructKeys.borrowed_by)
            let img_url: String = try item_container.decode(String.self, forKey: itemStructKeys.imgURL)
            let color: String = try item_container.decode(String.self, forKey: itemStructKeys.color)
            let size: String = try item_container.decode(String.self, forKey: itemStructKeys.size)
            let price: Double = try item_container.decode(Double.self, forKey: itemStructKeys.price)
            let category: String = try item_container.decode(String.self, forKey: itemStructKeys.category)
            let item = Item(item_id: item_id, name: i_name, owner: owner, borrowed: borrowed_b, borrowed_by: borrowed_by, imgURL: img_url, color: color, size: size, price: price, category: category);
            borrowed.append(item);
        }
        var closet_array = try container.nestedUnkeyedContainer(forKey: userStructKeys.closet);
        var closet: [Item] = [];
        while (!closet_array.isAtEnd) {
            let item_container = try closet_array.nestedContainer(keyedBy: itemStructKeys.self)
            let i_name: String = try item_container.decode(String.self, forKey: itemStructKeys.name)
            let item_id: Int = try item_container.decode(Int.self, forKey: itemStructKeys.item_id) // extracting the data
            let owner: Int = try item_container.decode(Int.self, forKey: itemStructKeys.owner)
            let borrowed_b: Bool = try item_container.decode(Bool.self, forKey: itemStructKeys.borrowed)
            let borrowed_by: Int = try item_container.decode(Int.self, forKey: itemStructKeys.borrowed_by)
            let img_url: String = try item_container.decode(String.self, forKey: itemStructKeys.imgURL)
            let color: String = try item_container.decode(String.self, forKey: itemStructKeys.color)
            let size: String = try item_container.decode(String.self, forKey: itemStructKeys.size)
            let price: Double = try item_container.decode(Double.self, forKey: itemStructKeys.price)
            let category: String = try item_container.decode(String.self, forKey: itemStructKeys.category)
            let item = Item(item_id: item_id, name: i_name, owner: owner, borrowed: borrowed_b, borrowed_by: borrowed_by, imgURL: img_url, color: color, size: size, price: price, category: category);
            closet.append(item);
        }
        self.init(user_ID: user_ID,profPic: profPic, name: name, borrowed: borrowed, closet: closet) // initializing our struct
        
    }
}

let json = """
[{
    "user_ID": 123,
    "owner": "Chloe Imaginary",
    "profPic": "chloe.png",
    "borrowed": [{
        "item_id": 54321,
        "name": "Formal shirt",
        "owner": 321,
        "borrowed": true,
        "borrowed_by": 123,
        "image": "r_img1.png",
        "color_tag": "blue",
        "size": "M",
        "price": 35,
        "category": "shirt"
    }],
    "closet": [{
        "item_id": 12345,
        "name": "Formal shirt",
        "owner": 123,
        "borrowed": true,
        "borrowed_by": 321,
        "image": "c_img1.png",
        "color_tag": "red",
        "size": "M",
        "price": 70,
        "category": "shirt"
    }, {
        "item_id": 14445,
        "name": "Fun shirt",
        "owner": 123,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "c_img2.png",
        "color_tag": "red",
        "size": "M",
        "price": 50,
        "category": "shirt"
    }, {
        "item_id": 16645,
        "name": "Superhero shirt",
        "owner": 123,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "c_img3.png",
        "color_tag": "green",
        "size": "M",
        "price": 40,
        "category": "shirt"
    }, {

        "item_id": 17745,
        "name": "bright shirt",
        "owner": 123,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "c_img4.png",
        "color_tag": "red",
        "size": "M",
        "price": 30,
        "category": "shirt"
    }, {
        "item_id": 17845,
        "name": "frayed jeans",
        "owner": 123,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "c_img5.png",
        "color_tag": "blue",
        "size": "S",
        "price": 80,
        "category": "pant"
    }]
}, {
    "user_ID": 321,
    "owner": "Rhea Karuturi",
    "profPic": "rhea.png",
    "borrowed": [{
        "item_id": 12345,
        "name": "Formal shirt",
        "owner": 123,
        "borrowed": true,
        "borrowed_by": 321,
        "image": "c_img1.png",
        "color_tag": "red",
        "size": "M",
        "price": 70,
        "category": "shirt"
    }],
    "closet": [{
        "item_id": 54321,
        "name": "Formal shirt",
        "owner": 321,
        "borrowed": true,
        "borrowed_by": 123,
        "image": "r_img1.png",
        "color_tag": "blue",
        "size": "M",
        "price": 35,
        "category": "shirt"
    }, {
        "item_id": 54322,
        "name": "frilly shirt",
        "owner": 321,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "r_img2.png",
        "color_tag": "red",
        "size": "S",
        "price": 65,
        "category": "shirt"
    }, {
        "item_id": 54323,
        "name": "summer tank top",
        "owner": 321,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "r_img3.png",
        "color_tag": "white",
        "size": "S",
        "price": 55,
        "category": "shirt"
    }, {
        "item_id": 54324,
        "name": "fun, flared skirt",
        "owner": 321,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "r_img4.png",
        "color_tag": "yellow",
        "size": "S",
        "price": 76,
        "category": "skirt"
    }, {
        "item_id": 54325,
        "name": "ripped jeans",
        "owner": 321,
        "borrowed": false,
        "borrowed_by": 0,
        "image": "r_img5.png",
        "color_tag": "black",
        "size": "S",
        "price": 90,
        "category": "pant"
    }]
}]
""".data(using: .utf8)!

class ClosetViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currUser = a_User(user_ID: 123, profPic: "", name: "", borrowed: [], closet: []);
    var user_num = 321;
    var currArray: [Item] = [];
    let sectionInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    let itemsPerRow: CGFloat = 2.0
    var status_lending = true

    @IBOutlet weak var tabPicker: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var viewOfItems: UICollectionView!
   @IBOutlet weak var profileName: UILabel!
    

    //Replace with the uploadItemButton
    @IBAction func uploadItemButton(_ sender: UIButton) {
        self.showActionSheet();
    }
    
    @objc func showActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Import Image", message: "Take a picture or select one from your library.", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            startWithCamera = true
            self.performSegue(withIdentifier: "toCameraPage", sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            startWithCamera = false
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            itemImage = selectedImage!
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "toAddItemPage", sender: self)
            })
        } else if let originalImage = info[.originalImage] as? UIImage{
            selectedImage = originalImage
            itemImage = selectedImage!
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "toAddItemPage", sender: self)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        var myStructArray:[a_User] = [];
        do {
            try myStructArray = JSONDecoder().decode([a_User].self, from: json);
        }
        catch {
            print("array didn't work");
        }
        for stru in myStructArray {
            if stru.user_ID == user_num {
                currUser = stru;
            }
        }
    }
    
    func loadProfImage() {
        let image = UIImage(named: currUser.profPic);
        self.profilePicture.image = image;
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
    }
    
    func showUserName() {
        let userName = currUser.name;
       self.profileName.text = userName;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //for clothes you are lending
        if (status_lending) {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "lendingCell",for: indexPath) as! ItemCell
            let i = currArray[indexPath.row]
            cell.itemName.text = i.name;
            cell.img_display.image = UIImage(named: i.imgURL);
            cell.img_display.contentMode = .scaleToFill;
            cell.img_display.layer.borderWidth = 1;
            if (i.borrowed) {
                cell.backgroundColor = UIColor.lightGray
                cell.due_display.text = "1 day left";
                cell.due_display.textColor = UIColor.red;
            } else {
                cell.backgroundColor = UIColor.white
                cell.due_display.text = "not borrowed";
                cell.due_display.textColor = UIColor.black;
            }
            return cell
        } // for borrowing clothes
        else {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "borrowingCell",for: indexPath) as! BorrowedCell
            let i = currArray[indexPath.row]
            cell.img_display.image = UIImage(named: i.imgURL);
            cell.img_display.contentMode = .scaleToFill;
            cell.img_display.layer.borderWidth = 1;
            cell.dist_display.text = "1.2 mi";
            cell.due_display.text = "Due in 2 days";
            cell.due_display.textColor = UIColor.black;
            cell.price_display.text = String(i.price);
            cell.backgroundColor = UIColor.white
            return cell
        }

    }
    


    func loadLending() {
        currArray = currUser.closet;
        status_lending = true;
    }
    
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch tabPicker.selectedSegmentIndex
        {
        case 0:
            loadLending();
        case 1:
            currArray = currUser.borrowed;
            status_lending = false;
        default:
            break
        }
       self.viewOfItems.reloadData();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData();
        loadProfImage();
        showUserName();
        loadLending();
        uploadButton.imageView?.contentMode = .scaleAspectFit;
        uploadButton.layer.cornerRadius = 5;
        viewOfItems.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        //let availableWidth = viewOfItems.frame.size.width-(10*6.5);
        //let widthPerItem = availableWidth / 2;
        let widthPerItem = (UIScreen.main.bounds.width / 2) - 3
        let layout = UICollectionViewFlowLayout()
        //let layout = viewOfItems.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.minimumInteritemSpacing = 1;
        layout.itemSize = CGSize( width: widthPerItem, height: widthPerItem*1.3)
    
        viewOfItems.collectionViewLayout = layout

        
    }
   

}


