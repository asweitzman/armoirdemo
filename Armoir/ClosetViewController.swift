//
//  ClosetViewController.swift
//  Armoir
//
//  Created by alex weitzman on 11/30/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import Firebase

var documentsURL: URL = NSURLComponents().url!

let currentUser = Auth.auth().currentUser
let storageRef = Storage.storage().reference()

class ClosetViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var noItemsLabel: UILabel!
    
    var lentArray: [closet_item] = []
    var closetArray: [closet_item] = []
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    let itemsPerRow: CGFloat = 2.0
    let imageCache = NSCache<NSString, UIImage>()

    var status_borrowing = false
    var status_lending = false
    var status_closet = true
    
    var user = Auth.auth().currentUser

    @IBOutlet weak var tabPicker: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var viewOfItems: UICollectionView!
   @IBOutlet weak var profileName: UILabel!
    

    //Replace with the uploadItemButton
    @IBAction func uploadItemButton(_ sender: UIButton) {
        self.showActionSheet();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        loadLentArray()
        if (status_lending) {
            loadLending()
        }
        if (status_borrowing) {
            loadBorrowing()
        }
        if (status_closet) {
            loadCloset()
        }
        viewOfItems.reloadData()
    }
    
    func downloadImage(imageName: String, url: URL) -> UIImage{
        let imageRef = storageRef.child("images/" + String(imageName))
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
              return cachedImage
        }
        let data = try? Data(contentsOf: url)
        let image = UIImage(data: data!)
        let thumb1 = image?.resized(By: 0.5)
        self.imageCache.setObject(thumb1!, forKey: url.absoluteString as NSString)
        return thumb1 as! UIImage;
    }
    
    func loadBorrowing() {
        currFirebaseArray = firebaseUser.borrowed ?? [];
        status_lending = false;
        status_closet = false;
    }
    
    @objc func showActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Import Image", message: "Take a picture or select one from your library.", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            startWithCamera = true
            imagePickerController.sourceType = .camera

            self.present(imagePickerController, animated: true, completion: nil)
            //self.performSegue(withIdentifier: "toCameraPage", sender: self)
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
        
        // extract image from the picker and save it
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            //ImageRetriever().save(image: editedImage);
            itemImage = selectedImage!
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "toAddItemPage", sender: self)
            })
        } else if let originalImage = info[.originalImage] as? UIImage{
            selectedImage = originalImage
            //ImageRetriever().save(image: originalImage);
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
            let ref = Database.database().reference()
            //let currUser = Auth.auth().currentUser
            //1. read json from file: DONE
            var longJsonData = ""
            //let url = Bundle.main.url(forResource: "search", withExtension: "json")!
           // let url = URL(string: fullDestPathString)
            do {
                //let jsonData = try Data(contentsOf: fullDestPath)
                let user = ref.child("users").child(currentUser!.uid)
                user.observeSingleEvent(of: .value) { (snapshot) in
                    if let value = snapshot.value as? [String : Any] {
                    let json = try? JSONSerialization.data(withJSONObject: value, options: [])
                    if let JSONString = String(data: json!, encoding: String.Encoding.utf8) {
                       print("json string: " + JSONString)
                    }
                    do {
                        try firebaseUser = JSONDecoder().decode(firebase_User.self, from: json!)
                    } catch let error {
                        print("there is an error")
                        print(error)
                    }
                    }
                }
                //try all_users = JSONDecoder().decode([a_User].self, from: jsonData);
            }
            catch {
                print("read error:")
                print(error)
            }

            //2. when adding, add to the all_users array: to do in code


            //3. then, encode it to be in json
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(all_users)
                longJsonData = String(data: data, encoding: .utf8)!
                //print(String(data: data, encoding: .utf8)!)
                print("DONE ENCODING")
            }
            catch {
                print("array didn't work");
            }
            //print(longJsonData)

            //4. write to search.json with new encoded string
            let text = longJsonData
             do {
                 try text.write(toFile: fullDestPathString, atomically: true, encoding: String.Encoding.utf8)
                 print(fullDestPathString)
             }
             catch {
                print("write error:")
                 print(error)
             }
            
    //        let path = "test2" //this is the file. we will write to and read from it
    //        print("continuing");
    //        let text = longJsonData //just a text
    //        if let fileURL = Bundle.main.url(forResource: path, withExtension: "json") {
    //            //print(fileURL)
    //            //writing
    //            do {
    //                try text.write(to: fileURL, atomically: false, encoding: .utf8)
    //                print("tried to write")
    //                let url = Bundle.main.url(forResource: "search", withExtension: "json")!
    //                do {
    //                    let jsonData = try Data(contentsOf: url)
    //                    all_users = try JSONDecoder().decode([a_User].self, from: jsonData);
    //                    //print(newArray)
    //                }
    //                catch {
    //                    print(error)
    //                }
    //            }
    //            catch {
    //                print ("oh no");
    //            }
    //        }
            
    //        for user_instance in all_users {
    //            if user_instance.user_ID == user_num {
    //                currUser = user_instance;
    //            }
    //        }
        }
    
    func loadProfImage() {
        if let url = currentUser?.photoURL {
            let data = try? Data(contentsOf: url)
            //let image = UIImage(named: currUser.profPic);
            let image = try? UIImage(data: data!)
            self.profilePicture.image = image as! UIImage
        }
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        
    }
    
    func showUserName() {
        self.profileName.text = currentUser?.displayName;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return currArray.count
        return currFirebaseArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var ref = Database.database().reference()
        //for clothes you are lending
        
        if (status_closet) {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "lendingCell",for: indexPath) as! ItemCell
            if closetArray.isEmpty {
                cell.isUserInteractionEnabled = false
                cell.itemName.isHidden = true
                cell.due_display.isHidden = true
                noItemsLabel.isHidden = false
                noItemsLabel.text = "You haven't uploaded any items yet."
                return cell
            } else {
                cell.isUserInteractionEnabled = true
                cell.itemName.isHidden = false
                cell.due_display.isHidden = false
                noItemsLabel.isHidden = true
            }
            let i = closetArray[indexPath.row]
            cell.itemName.text = i.name;
            cell.backgroundColor = UIColor(red: 252, green: 246, blue: 240, alpha: 1)
            let imageRef = storageRef.child("images/" + String(i.image))
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("image url error")
                } else {
                    cell.img_display.image = self.downloadImage(imageName: String(i.image), url: url!)
                }
            }
            cell.img_display.contentMode = .scaleAspectFit;
//            cell.img_display.layer.borderWidth = 1;
            cell.backgroundColor = UIColor.white
            cell.due_display.text = "Not borrowed";
            cell.due_display.textColor = UIColor.black
            
            return cell
        }
        
        else if (status_lending) {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "lendingCell",for: indexPath) as! ItemCell
            if lentArray.isEmpty {
                cell.isUserInteractionEnabled = false
                cell.itemName.isHidden = true
                cell.due_display.isHidden = true
                noItemsLabel.isHidden = false
                noItemsLabel.text = "No one has borrowed from you yet."
                return cell
            } else {
                cell.isUserInteractionEnabled = true
                cell.itemName.isHidden = false
                cell.due_display.isHidden = false
                noItemsLabel.isHidden = true
            }
            let i = lentArray[indexPath.row]
//            var closetRef = ref.child("users").child(user!.uid).child("closet")
            //let i = currArray[indexPath.row]
            
//            let i = currFirebaseArray[indexPath.row]
            cell.itemName.text = i.name;
            cell.backgroundColor = UIColor(red: 252, green: 246, blue: 240, alpha: 1)
            let imageRef = storageRef.child("images/" + String(i.image))
//            imageRef.downloadURL { url, error in
//              if let error = error {
//                print("image download error")
//              } else {
//                let data = try? Data(contentsOf: url!)
//                let image = try? UIImage(data: data!)
//                cell.img_display.image = image as! UIImage;
//              }
//            }
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("image url error")
                } else {
                    cell.img_display.image = self.downloadImage(imageName: String(i.image), url: url!)
                }
            }
/*            let imgURL = i.image
            if (ImageRetriever().fileIsURL(fileName: imgURL)) {
                cell.img_display.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
            } else {
                cell.img_display.image = UIImage(named: i.image);
            }
*/          cell.img_display.contentMode = .scaleAspectFit;
//            cell.img_display.layer.borderWidth = 1;
            
//            if (i.borrowed) {
//            cell.backgroundColor = UIColor(hue: 0.0028, saturation: 0, brightness: 0.82, alpha: 1.0)
            
            cell.due_display.text = "1 day left";
            cell.due_display.textColor = UIColor(hue: 0.0028, saturation: 0.97, brightness: 0.65, alpha: 1.0);
            
            return cell
    } // for borrowing clothes
        
        else {
            
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "borrowingCell",for: indexPath) as! BorrowedCell
            //let i = currArray[indexPath.row]
            
            if currFirebaseArray.isEmpty {
                cell.isUserInteractionEnabled = false
                noItemsLabel.isHidden = false
                cell.dist_display.isHidden = true
                cell.due_display.isHidden = true
                cell.price_display.isHidden = true
                noItemsLabel.text = "You haven't borrowed any items yet."
                print("it's empty yo")
                return cell
            } else {
                print("it's not empty yo")
                cell.isUserInteractionEnabled = true
                cell.dist_display.isHidden = false
                cell.due_display.isHidden = false
                cell.price_display.isHidden = false
                noItemsLabel.isHidden = true
            }
            
            let i = currFirebaseArray[indexPath.row]
/*            let imgURL = i.image
            if (ImageRetriever().fileIsURL(fileName: imgURL)) {
                cell.img_display.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
            } else {
                
                cell.img_display.image = UIImage(named: i.image);
    
            }
 */
            let imageRef = storageRef.child("images/" + String(i.image))
            imageRef.downloadURL { url, error in
              if let error = error {
                print("image download error")
              } else {
                let data = try? Data(contentsOf: url!)
                let image = try? UIImage(data: data!)
                cell.img_display.image = image as! UIImage;
              }
            }
            cell.img_display.contentMode = .scaleAspectFit;
//            cell.img_display.layer.borderWidth = 1;
            cell.dist_display.text = "1.2 mi";
            cell.due_display.text = "Due in 10 days";
            cell.due_display.textColor = UIColor.black;
            cell.price_display.text = String(format: "%f", i.price);
            cell.backgroundColor = UIColor.white
            return cell
        }
    }
    
    func loadCloset() {
        currFirebaseArray = firebaseUser.closet ?? [];
        status_lending = false;
        status_borrowing = false;
        status_closet = true;
    }

    func loadLending() {
        //currArray = currUser.closet;
        currFirebaseArray = firebaseUser.closet ?? [];
        status_lending = true;
        status_borrowing = false;
        status_closet = false;
    }
    
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch tabPicker.selectedSegmentIndex
        {
        case 0:
            loadLending();
        case 1:
            loadCloset();
        case 2:
            loadBorrowing();
        default:
            loadCloset()
        }
       self.viewOfItems.reloadData();
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //currItem = currArray[indexPath.row].item_id;
        currItem = currFirebaseArray[indexPath.row].item_id

    }
    
    func loadLentArray() {
        let closetArr = firebaseUser.closet ?? [];
        
        for item in closetArr {
            if (item.borrowed) {
                lentArray.append(item)
            } else {
                closetArray.append(item)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
                // Move '/Documents/filename.hello.swift' to  '/Documents/Folder/filename/hello.swift'
        do {
            try fileManager.copyfileToUserDocumentDirectory(forResource: "search", ofType: "json")
                //try fileManager.moveItem(atPath: "search.json", toPath:
             //"/Documents/search.json")
            print("successfully moved")
            }
        catch let error as NSError {
              print("it did not worked\(error)")
        }
        loadData();
        loadLentArray();
        loadCloset();
        loadProfImage();
        showUserName();
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

extension FileManager {
    func copyfileToUserDocumentDirectory(forResource name: String,
                                         ofType ext: String) throws
    {
        if let bundlePath = Bundle.main.path(forResource: name, ofType: ext),
            let URL1 = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                .userDomainMask,
                                true).first {
            let fileName = "\(name).\(ext)"
            documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //documentsURL = URL(fileURLWithPath: URL1)
            //fullDestPath = documentsURL.appendingPathComponent(fileName)
            fullDestPath = URL(fileURLWithPath: URL1)
                                   .appendingPathComponent(fileName)
            fullDestPathString = fullDestPath.path
            print("full dest path:")
            print(fullDestPathString)
            if !self.fileExists(atPath: fullDestPathString) {
                try self.copyItem(atPath: bundlePath, toPath: fullDestPathString)
            }
        }
    }
}
