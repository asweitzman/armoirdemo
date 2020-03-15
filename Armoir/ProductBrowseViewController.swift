//
//  ProductBrowseViewController.swift
//  Armoir
//
//  Created by alex weitzman on 11/29/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown
import Firebase

var clickedIndex:Int = Int()
var productImageURLs:[String] = [String]()
var readableJSON:JSON = JSON()
var allItems = [closet_item]()
var itemData:[closet_item] = [closet_item]()
var otherUsers:[a_User] = [];
var currCategory:Int = Int()
var categories:[String] = [String]()
var sizes:[String] = [String]()
let categoryDropDown:DropDown = DropDown()
let filterDropDown:DropDown = DropDown()
let sortByDropDown:DropDown = DropDown()
var keywords:[String] = [String]()
var categorySet:Bool = Bool()
var currSizeIndex:Int = Int()
var chosenItem = closet_item(item_id: 0, borrowed: false, borrowed_by: "0", category: "", color: "", image: "", name: "", owner: "", price: 0, size: "", distance: 0)
var sortType:Int = Int()
var currUserJSON:JSON = JSON()

class ProductBrowseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var fullArray: [closet_item] = [];
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var showingLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var sortByButton: UIButton!
    
    @IBOutlet weak var searchFieldText: UISearchBar!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(imageName: String, url: URL) -> UIImage{
        let imageRef = storageRef.child("images/" + String(imageName))
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            print("image is cached")
              return cachedImage
        }
        
        print(imageCache)
        let data = try? Data(contentsOf: url)
        let image = UIImage(data: data!)
//        let thumb1 = image?.resized(By: 0.25)
        self.imageCache.setObject(image!, forKey: url.absoluteString as NSString)
        return image as! UIImage;
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false;
        searchFieldText.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
                //searchBar.endEditing(true)
            }
            //searchBar.resignFirstResponder()
            //reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchQuery = searchFieldText.text! as NSString
        keywords = searchQuery.lowercased.components(separatedBy: " ")
        print(keywords)
        reloadData()
    }

   /* @IBAction func tapToHideKeyboard(_ sender: Any) {
        self.searchFieldText.resignFirstResponder()
    }*/
    
    @IBAction func categoryClicked(_ sender: Any) {
        categoryDropDown.show()
    }
    
    
    @IBAction func filterClicked(_ sender: Any) {
        filterDropDown.show()
        
    }
    
    @IBAction func sortByClicked(_ sender: Any) {
        sortByDropDown.show()
    }
    

    
    func getData() {
//        if let path = Bundle.main.path(forResource: "search", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                readableJSON = try JSON(data: data)
//            } catch {
//                print("Error reading json file")
//            }
//        }
        
        let ref = Database.database().reference()
        do {
            //let jsonData = try Data(contentsOf: fullDestPath)
            let user = ref.child("items")
            user.observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value
                print("here")
                //readableJSON = try? JSONSerialization.jsonObject(with: value, options: [])
                let json = try? JSONSerialization.data(withJSONObject: value, options: [])
                if let JSONString = String(data: json!, encoding: String.Encoding.utf8) {
                   print("json string: " + JSONString)
                }
                do {
                    allItems = try JSONDecoder().decode([closet_item].self, from: json!)
                } catch let error {
                    print(error)
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
/*        let encoder = JSONEncoder()
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
 */
        print("data retreived")
    }

    func sortDistanceLowHigh(this:closet_item, that:closet_item) -> Bool {
        return this.distance < that.distance
    }
    
    func sortPriceLowHigh(this:closet_item, that:closet_item) -> Bool {
        return  this.price < that.price
    }
    
    func sortPriceHighLow(this:closet_item, that:closet_item) -> Bool {
        return  this.price > that.price
    }
/*
    func sortDistanceLowHigh(this:firebase_User, that:firebase_User) -> Bool {
        let thisDist = this.distance
        let thatDist = that.distance
        let thisDistNS = thisDist as NSString
        let thatDistNS = thatDist as NSString
        let thisDistArr = thisDistNS.components(separatedBy: " ")
        let thatDistArr = thatDistNS.components(separatedBy: " ")
        
        let thisDistFirst = thisDistArr[0]
        let thatDistFirst = thatDistArr[0]
        
        return Double(thisDistFirst)! < Double(thatDistFirst)!
    }
*/
    
    func reloadData() {
        itemData = []
        let currentUser = Auth.auth().currentUser
        for item in allItems {
            if item.owner != currentUser?.uid {
                var keywordMatch = true
                if (!keywords.isEmpty && keywords[0] != "") {
                    keywordMatch = false
                    let itemName = item.name
                    let nameWords = itemName.lowercased().components(separatedBy: " ")
                    for word in nameWords {
                        for keyword in keywords {
                            if (word == keyword) { keywordMatch = true }
                        }
                    }
                } else {
                    keywordMatch = true
                }
                if(keywordMatch) {
                    if (categorySet) {
                        if(item.category == categories[currCategory]) {
                            if (currSizeIndex == 5) {
                                itemData.append(item)
                            } else if (item.size == sizes[currSizeIndex]) {
                                itemData.append(item)
                            }
                        }
                    } else {
                        if (currSizeIndex == 5) {
                            itemData.append(item)
                        } else if (item.size == sizes[currSizeIndex]) {
                            itemData.append(item)
                        }
                    }
                }
            }
        }
        if (sortType == 0) {
            itemData.sort(by: sortPriceLowHigh)
        } else if (sortType == 1) {
            itemData.sort(by: sortPriceHighLow)
        } else if (sortType == 2) {
            itemData.sort(by: sortDistanceLowHigh)
        }
        myCollectionView.reloadData()
    }
   
    func loadData() {
        itemData = []
        let currentUser = Auth.auth().currentUser
        for item in allItems {
            if item.owner != currentUser?.uid {
                var keywordMatch = true
                if (!keywords.isEmpty && keywords[0] != "") {
                    keywordMatch = false
                    let itemName = item.name
                    let nameWords = itemName.lowercased().components(separatedBy: " ")
                    for word in nameWords {
                        for keyword in keywords {
                            if (word == keyword) { keywordMatch = true }
                        }
                    }
                } else {
                    keywordMatch = true
                }
                if(keywordMatch) {
                    if (categorySet) {
                        if(item.category == categories[currCategory]) {
                            if (currSizeIndex == 5) {
                                itemData.append(item)
                            } else if (item.size == sizes[currSizeIndex]) {
                                itemData.append(item)
                            }
                        }
                    } else {
                        if (currSizeIndex == 5) {
                            itemData.append(item)
                        } else if (item.size == sizes[currSizeIndex]) {
                            itemData.append(item)
                        }
                    }
                }
            }
        }
//        if (sortType == 0) {
//            itemData.sort(by: sortPriceLowHigh)
//        } else if (sortType == 1) {
//            itemData.sort(by: sortPriceHighLow)
//        } else if (sortType == 2) {
//            itemData.sort(by: sortDistanceLowHigh)
//        }
//        myCollectionView.reloadData()

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collection view")
        getData()
        //loadData()
        reloadData()
        print("num items in array: " + String(itemData.count))
        return itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getData()
        //loadData()
        reloadData()
        chosenItem = itemData[indexPath.row]
        currItem = chosenItem.item_id
        self.performSegue(withIdentifier: "toItemDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! ProductCell
        
        let currItem = itemData[indexPath.row]
        //print(currItem)
//        cell.productImage.image = UIImage(named: currItem["image"].string!)
//        if let imageStr = currItem["image"].string {
//            cell.productImage.image = UIImage(named: imageStr)
//        }
        let imageRef = storageRef.child("images/" + String(currItem.image))
//        imageRef.downloadURL { url, error in
//          if let error = error {
//            print("image download error")
//          } else {
//            let data = try? Data(contentsOf: url!)
//            let image = UIImage(data: data!)
//            let thumb1 = image?.resized(withPercentage: 0.5)
//            cell.productImage.image = thumb1 as! UIImage;
//          }
//        }
        imageRef.downloadURL { url, error in
            if let error = error {
                print("image url error")
            } else {
                //cell.productImage.image = self.downloadImage(imageName: String(currItem.image), url: url!)
                cell.productImage.loadImageUsingCacheWithUrlString(url!.absoluteString)
            }
        }
        let currPrice = currItem.price
        cell.productPrice.text = "$" + String(currPrice) + "/day";
        let dist = currItem.distance
        let distString = String(format: "%.1f", dist)
        cell.productDistance.text = distString + " mi."
        cell.productImage.contentMode = .scaleAspectFit;
        //cell.productImage.layer.borderWidth = 1;
        //cell.productDistance.text = currItem["distance"].string! + " mi";
        cell.backgroundColor = .white
        //cell.backgroundColor = hexStringToUIColor(hex: "#FCF6F0")
        print("cell: " + String(cell.productPrice.text ?? ""))
        return cell
    }
    
    /*let category = DropDown()
    let filter = DropDown()
    let sortby = DropDown()
    
    func initCategory(){
        category.dataSource = ["All", "Shirt", "Pants", "Shorts", "Dresses", "Skirts", "Outerwear", "Shoes", "Accessories", "Other" ]
        
        category.selectionAction = {[weak self] (index: Int, item: String) in
            
            print("Selected item: \(item) at index: \(index)")
        }
        category.cellNib = UINib(nibName: "cell”, bundle: nil)
    }
    
    func initFilter(){
        filter.dataSource = ["??"]
        filter.bottomOffset = CGPoint(x: 0, y:(filter.anchorView?.plainView.bounds.height)!)
    }
    
    func initSortBy(){
        sortby.dataSource = ["Price: low->high","Price: high->low", "Distance"]
        sortby.bottomOffset = CGPoint(x: 0, y:(sortby.anchorView?.plainView.bounds.height)!)
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        getData()
        loadData()
        reloadData()
    }
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
//        let icon = UIImage(named: "downarrow3")!
//        categoryButton.setImage(icon, for: .normal)
//        categoryButton.imageView?.contentMode = .scaleAspectFit
//        categoryButton.semanticContentAttribute = UIApplication.shared
//            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
//        categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: categoryButton.frame.size.width - categoryButton.titleLabel!.intrinsicContentSize.width + 5, bottom: 0, right: 0)
//        filterButton.setImage(icon, for: .normal)
//        filterButton.imageView?.contentMode = .scaleAspectFit
//        filterButton.semanticContentAttribute = UIApplication.shared
//            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
//        filterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: filterButton.frame.size.width - filterButton.titleLabel!.intrinsicContentSize.width - 40, bottom: 0, right: 0)
//        sortByButton.setImage(icon, for: .normal)
//        sortByButton.imageView?.contentMode = .scaleAspectFit
//        sortByButton.semanticContentAttribute = UIApplication.shared
//            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
//        sortByButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: sortByButton.frame.size.width - sortByButton.titleLabel!.intrinsicContentSize.width, bottom: 0, right: 0)
        
        sortType = 0
        categorySet = false
        currSizeIndex = 5
        categories = ["Shirt", "Pants", "Skirt", "Shorts", "Dress", "Outerwear"]
        sizes = ["XS", "S", "M", "L", "XL"]
//        getData()
//        loadData()
//        reloadData()
        
        initDropDowns()
        initCategoryDropDown()
        initFilterDropDown()
        initSortByDropDown()
        
        let itemSize = (UIScreen.main.bounds.width / 2) - 3
        let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: itemSize, height: itemSize*1.3)
        
        layout.minimumInteritemSpacing = 1
        //layout.minimumLineSpacing = 7
        
        myCollectionView.collectionViewLayout = layout
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func initDropDowns() {
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont(name: "WorkSans-Regular", size: 17)!
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().cellHeight = 60
        //shadeDropDown.width = 154
        
        categoryDropDown.anchorView = categoryButton
        filterDropDown.anchorView = filterButton
        sortByDropDown.anchorView = sortByButton
        
        categoryDropDown.direction = .bottom
        filterDropDown.direction = .bottom
        sortByDropDown.direction = .bottom
        
        categoryDropDown.dismissMode = .automatic
        filterDropDown.dismissMode = .automatic
        sortByDropDown.dismissMode = .automatic
        
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        filterDropDown.bottomOffset = CGPoint(x: 0, y:(filterDropDown.anchorView?.plainView.bounds.height)!)
        sortByDropDown.bottomOffset = CGPoint(x: 0, y:(sortByDropDown.anchorView?.plainView.bounds.height)!)
    }
    
    func initCategoryDropDown() {
        let capsCategories = ["Shirt", "Pants", "Skirts", "Shorts", "Dresses", "Outerwear", "All items"]
        categoryDropDown.dataSource = capsCategories
        
        categoryDropDown.selectionAction = { [weak self] (index: Int, _: String) in
            if (index == (capsCategories.count-1)) {
                categorySet = false
                self?.reloadData()
                self?.categoryButton.titleLabel!.text = "All items"
            } else {
                categorySet = true
                //print(index)
                currCategory = index
                self?.categoryButton.titleLabel!.text = capsCategories[index]
                self?.reloadData()
            }
        }
    }
    
    func initFilterDropDown() {
        let sizes = ["XS", "S", "M", "L", "XL", "All"]
        filterDropDown.dataSource = sizes
        
        filterDropDown.selectionAction = { [weak self] (index: Int, _: String) in
            currSizeIndex = index
            self?.filterButton.titleLabel!.text = sizes[index]
            self?.reloadData()
        }
    }
    
    func initSortByDropDown() {
        sortByDropDown.dataSource = ["Price: Low to high", "Price: High to low", "Distance: Low to high"]
        
        sortByDropDown.selectionAction = { [weak self] (index: Int, _: String) in
            sortType = index
            self?.reloadData()
        }
    }


    /*func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //currItem = fullArray[indexPath.row].item_id;
        currItem = itemData[indexPath.row]["item_id"].int!
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {

    func resized(By coefficient:CGFloat) -> UIImage? {

        guard coefficient >= 0 && coefficient <= 1 else {

            print("The coefficient must be a floating point number between 0 and 1")
            return nil
        }

        let newWidth = size.width * coefficient
        let newHeight = size.height * coefficient

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))

        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }
}
