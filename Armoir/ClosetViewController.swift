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

class ClosetViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    let itemsPerRow: CGFloat = 2.0
    //let currentUser = Auth.auth().currentUser
    var status_lending = true
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
        if (status_lending) {
            loadLending()
        } else {
            loadBorrowing()
        }
        viewOfItems.reloadData()
    }
    
    func loadBorrowing() {
        currArray = currUser.borrowed;
        status_lending = false;
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
        
        //1. read json from file: DONE
        var longJsonData = ""
        //let url = Bundle.main.url(forResource: "search", withExtension: "json")!
       // let url = URL(string: fullDestPathString)
        do {
            let jsonData = try Data(contentsOf: fullDestPath)
            try all_users = JSONDecoder().decode([a_User].self, from: jsonData);

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
        
        for user_instance in all_users {
            if user_instance.user_ID == user_num {
                currUser = user_instance;
            }
        }
    }
    
    func loadProfImage() {
        if let url = currentUser?.photoURL {
            let data = try? Data(contentsOf: url)
            //let image = UIImage(named: currUser.profPic);
            let image = try? UIImage(data: data!)
            self.profilePicture.image = image as! UIImage;
        }
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        
    }
    
    func showUserName() {
        self.profileName.text = currentUser?.displayName;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var ref = Database.database().reference()
        //for clothes you are lending
        if (status_lending) {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "lendingCell",for: indexPath) as! ItemCell
//            var closetRef = ref.child("users").child(user!.uid).child("closet")
            let i = currArray[indexPath.row]
            cell.itemName.text = i.name;
            cell.backgroundColor = UIColor(red: 252, green: 246, blue: 240, alpha: 1)
            let imgURL = i.image
            if (ImageRetriever().fileIsURL(fileName: imgURL)) {
                cell.img_display.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
            } else {
                cell.img_display.image = UIImage(named: i.image);
            }
            cell.img_display.contentMode = .scaleAspectFit;
            cell.img_display.layer.borderWidth = 1;
            if (i.borrowed) {
                cell.backgroundColor = UIColor(hue: 0.0028, saturation: 0, brightness: 0.82, alpha: 1.0)
                cell.due_display.text = "1 day left";
                cell.due_display.textColor = UIColor(hue: 0.0028, saturation: 0.97, brightness: 0.65, alpha: 1.0);
            } else {
                cell.backgroundColor = UIColor.white
                cell.due_display.text = "Not borrowed";
                cell.due_display.textColor = UIColor.black;
            }
            return cell
        } // for borrowing clothes
        else {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "borrowingCell",for: indexPath) as! BorrowedCell
            let i = currArray[indexPath.row]
            let imgURL = i.image
            if (ImageRetriever().fileIsURL(fileName: imgURL)) {
                cell.img_display.image = ImageRetriever().loadImg(fileURL: URL(string: imgURL)!)
            } else {
                
                cell.img_display.image = UIImage(named: i.image);
            }
            cell.img_display.contentMode = .scaleAspectFit;
            cell.img_display.layer.borderWidth = 1;
            cell.dist_display.text = "1.2 mi";
            cell.due_display.text = "Due in 10 days";
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = currArray[indexPath.row].item_id;

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
