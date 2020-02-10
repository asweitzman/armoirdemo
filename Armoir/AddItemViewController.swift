//
//  AddItemViewController.swift
//  Armoir
//
//  Created by alex weitzman on 12/4/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import DropDown
import Firebase

let sizeDropDown:DropDown = DropDown()
let categoryDropDown2:DropDown = DropDown()
var itemCategory:String = String()
var itemSize:String = String()

class AddItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var missingDetailsLabel: UILabel!
    
    @IBOutlet weak var Description: UITextField!
    
    @IBOutlet weak var Price: UITextField! {
         didSet { Price?.addDoneCancelToolbar() }
    }
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var sizeButton: UIButton!

    
     @IBAction func tapToHideKeyboard(_ sender: Any) {
        self.Description.resignFirstResponder()
        self.Price.resignFirstResponder()
        
     }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Description.resignFirstResponder()
        return true
    }
    
    @IBAction func sizeClicked(_ sender: Any) {
        sizeDropDown.show()
    }
    
    @IBAction func categoryClicked(_ sender: Any) {
        categoryDropDown2.show()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
   // Analytics.logEvent("add_item_button_pressed", parameters: ["item" : "pressed"])
        
        if (Description.text == "" || Price.text == "" || categoryButton.titleLabel!.text == "Category" || sizeButton.titleLabel!.text == "Size") {
            
            missingDetailsLabel.isHidden = false
        } else {
        
        //let description: String = Description.text!
        //needs to be a double based on what they enter
        var imageURL = ""
        //if (!startWithCamera) {
            ImageRetriever().save(image: itemImage);
            imageURL = ImageRetriever().loadStr(fileName: "SavedImage" + String(numImgSaved))
            print(ImageRetriever().fileIsURL(fileName: imageURL))
        //}

        print("URL: " + imageURL)
            /*if let price = Double(price.text) {
                
            } else {
                
            }*/
        let price = Price.text!
        let priceDouble = Double(price)!
        let description = Description.text!
        var numItems = 0
        let category = "shirt"
        for u in all_users {
            for i in u.closet {
                numItems += 1
            }
        }
        
        if (imageURL != "") {}
            let new_item = Item(item_id: numItems+1, name: description, owner: currUser.user_ID, borrowed: false, borrowed_by: 0, image: imageURL, color: "", size: itemSize, price: priceDouble, category: itemCategory)
        
        //1. find index of currUser in all_users array
        var i = 0;
        var found = false;
        for u in all_users {
            if (u.user_ID == currUser.user_ID) {
                found = true
            }
            if (!found) {
                i += 1
            }
        }
        //2. use the index to change the actual element in all users
        //print (all_users[i]) //testing before
        var temp = all_users[i].closet
        temp.append(new_item)
        all_users[i].closet = temp
        print(all_users[i]) // testing after
        
        //to check if all_users updated
        //print(all_users)
        
        //encode to json
        var text = "" //just a text
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(all_users)
            text = String(data: data, encoding: .utf8)!
            print("DONE ENCODING")
            //print(String(data: data, encoding: .utf8)!)
        }
        catch {
            print("array didn't work");
        }
        
            
        //let fileName = "search.json"
            //let filePath = documentDirectory.appendingPathComponent("search.json").absoluteString

           // let filePath = (documentDirectory as NSString).stringByAppendingPathComponent("search.json")
           // let filePath = self.applicationDocumentsDirectory().path?.stringByAppendingString(fileName)

            do {
                try text.write(toFile: fullDestPathString, atomically: true, encoding: String.Encoding.utf8)
                print(fullDestPathString)
            }
            catch {
                print(error)
            }
                
        //
        /*let path = "search" //this is the file. we will write to and read from it
        print("continuing");
        
        if let fileURL = Bundle.main.url(forResource: path, withExtension: "json") {
            
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                print("tried to write")
            }
            catch {
                print(error)
            }
        }*/
            
            
            
//            let from = Bundle.main.url(forResource: "search", withExtension: "json")!
//
//            let to = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("result.json")
//
//            do {
//
//                try FileManager.default.copyItem(at: from, to: to)
//
//                print(try FileManager.default.contents(atPath: to.path))
//
//                let wer = Data("rerree".utf8 )
//
//                try wer.write(to: to)
//
//                print(try FileManager.default.contents(atPath: to.path))
//
//            }
//            catch {
//
//                print(error)
//            }
//
//            let fileName = "search"
//            let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("json")
//                print("File PAth: \(fileURL.path)")
            
            
        /*
        let new_item = Item(item_id: numItems+1, name: "Jean Jacket", owner: currUser.user_ID, borrowed: false, borrowed_by: 0, image: "jeanJacketFinal", color: "red", size: "M", price: price, category: category)
        
        /*let new_item = Item(item_id: numItems+1, name: description, owner: currUser.user_ID, borrowed: false, borrowed_by: 0, image: imageURL, color: color, size: "S", price: price, category: "shirt")*/
        
        for var u in all_users {
            if (u.user_ID == currUser.user_ID) {
                u.closet.append(new_item)
            }
        }
        */
        //currUser.closet.append(new_item)
        numImgSaved += 1
 
        //if (startWithCamera) {
           // print("true")
            // Go back two ViewControllers
            //_ = navigationController?.popViewControllers(viewsToPop: 1)
        //} else {
            _ = navigationController?.popViewControllers(viewsToPop: 1)
        //}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Description.delegate = self
        self.Description.returnKeyType = UIReturnKeyType.done
        self.Description.autocorrectionType = .no
        missingDetailsLabel.isHidden = true
//        let icon = UIImage(named: "downarrow3")!
//        categoryButton.setImage(icon, for: .normal)
//        categoryButton.imageView?.contentMode = .scaleAspectFit
//        categoryButton.semanticContentAttribute = UIApplication.shared
//            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
//        categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: categoryButton.frame.size.width - categoryButton.titleLabel!.intrinsicContentSize.width, bottom: 0, right: 0)
//        sizeButton.setImage(icon, for: .normal)
//        sizeButton.imageView?.contentMode = .scaleAspectFit
//        sizeButton.semanticContentAttribute = UIApplication.shared
//            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
//        sizeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: sizeButton.frame.size.width - sizeButton.titleLabel!.intrinsicContentSize.width, bottom: 0, right: 0)
        itemCategory = ""
        itemSize = ""
        
        initDropDowns()
        initcategoryDropDown2()
        initSizeDropDown()
        
        itemImageView.image = itemImage
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.hidesBackButton = false;
    }
    
    func initDropDowns() {
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont(name: "Alike-Regular", size: 17)!
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().cellHeight = 40
        
        categoryDropDown2.anchorView = categoryButton
        sizeDropDown.anchorView = sizeButton
        
        categoryDropDown2.direction = .bottom
        sizeDropDown.direction = .bottom
        
        categoryDropDown2.dismissMode = .automatic
        sizeDropDown.dismissMode = .automatic
        
        categoryDropDown2.bottomOffset = CGPoint(x: 0, y:(categoryDropDown2.anchorView?.plainView.bounds.height)!)
        sizeDropDown.bottomOffset = CGPoint(x: 0, y:(sizeDropDown.anchorView?.plainView.bounds.height)!)
    }
    
    func initcategoryDropDown2() {
        let categories = ["Shirt", "Pants", "Skirt", "Shorts", "Dress", "Outerwear"]
        categoryDropDown2.dataSource = categories
        
        categoryDropDown2.selectionAction = { [weak self] (index: Int, _: String) in
            itemCategory = categories[index]
            self?.categoryButton.setTitle(categories[index],for: .normal)
            print(itemCategory)
        }
    }
    
    func initSizeDropDown() {
        let sizes = ["XS", "S", "M", "L", "XL"]
        sizeDropDown.dataSource = sizes
        
        sizeDropDown.selectionAction = { [weak self] (index: Int, _: String) in
            itemSize = sizes[index]
            self?.sizeButton.setTitle(sizes[index],for: .normal)
            print(itemSize)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        //if (startWithCamera) {
        //    print("true")
        // Go back two ViewControllers
           // _ = navigationController?.popViewControllers(viewsToPop: 2)
        //} else {
            _ = navigationController?.popViewControllers(viewsToPop: 1)
        //}
        
    }

}

extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
    
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

