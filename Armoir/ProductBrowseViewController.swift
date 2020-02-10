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

var clickedIndex:Int = Int()
var productImageURLs:[String] = [String]()
var readableJSON:JSON = JSON()
var itemData:[JSON] = [JSON]()
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
var chosenItem:JSON = JSON()
var sortType:Int = Int()
var currUserJSON:JSON = JSON()

class ProductBrowseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    var fullArray: [Item] = [];
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var showingLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var sortByButton: UIButton!
    
    @IBOutlet weak var searchFieldText: UISearchBar!
    
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
        if let path = Bundle.main.path(forResource: "search", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                readableJSON = try JSON(data: data)
            } catch {
                print("Error reading json file")
            }
        }
    }

    func sortPriceLowHigh(this:JSON, that:JSON) -> Bool {
        return  this["price"].int! < that["price"].int!
    }
    
    func sortPriceHighLow(this:JSON, that:JSON) -> Bool {
        return  this["price"].int! > that["price"].int!
    }
    
    func sortDistanceLowHigh(this:JSON, that:JSON) -> Bool {
        let thisDist = this["distance"].string!
        let thatDist = that["distance"].string!
        let thisDistNS = thisDist as NSString
        let thatDistNS = thatDist as NSString
        let thisDistArr = thisDistNS.components(separatedBy: " ")
        let thatDistArr = thatDistNS.components(separatedBy: " ")
        
        let thisDistFirst = thisDistArr[0]
        let thatDistFirst = thatDistArr[0]
        
        return Double(thisDistFirst)! < Double(thatDistFirst)!
    }
    
    func reloadData() {
        itemData = []
        for (_,user) in readableJSON {
            if (user["user_ID"].int == currUser.user_ID) {
                currUserJSON = user
            }
        }
        
        for (_,user) in readableJSON {
            if (user["user_ID"].int != currUser.user_ID) {
                for (_,item) in user["closet"] {
                    var alreadyBorrowed = false
                    for (_,borrowedItem) in currUserJSON["borrowed"] {
                        if (item == borrowedItem) { alreadyBorrowed = true }
                    }
                    if (!alreadyBorrowed) {
                        var keywordMatch = true
                        if (!keywords.isEmpty && keywords[0] != "") {
                            keywordMatch = false
                            let itemName = item["name"].string!
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
                            
                                if(item["category"].string! == categories[currCategory]) {
                            
                                    if (currSizeIndex == 5) {
                                        itemData.append(item)
                                    } else if (item["size"].string! == sizes[currSizeIndex]) {
                                        itemData.append(item)
                                    }
                                
                                }

                            } else {

                                if (currSizeIndex == 5) {
                                    itemData.append(item)
                                } else if (item["size"].string! == sizes[currSizeIndex]) {
                                    itemData.append(item)
                                }
                            }
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
        /*
        var myStructArray:[a_User] = [];
        do {
            try myStructArray = JSONDecoder().decode([a_User].self, from: json);
        }
        catch {
            print("array didn't work");
        }
        for stru in myStructArray { */
        for stru in all_users {
            if stru.user_ID != user_num {
                otherUsers.append(stru);
            }
        }
        
        // add all the items
        for u in otherUsers {
            let cl = u.closet;
            for i in cl {
                if !(i.borrowed) {
                    fullArray.append(i);
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chosenItem = itemData[indexPath.row]
        currItem = chosenItem["item_id"].int!
        self.performSegue(withIdentifier: "toItemDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! ProductCell
        
        let currItem = itemData[indexPath.row]
        //print(currItem)
        cell.productImage.image = UIImage(named: currItem["image"].string!)
        if let imageStr = currItem["image"].string {
            cell.productImage.image = UIImage(named: imageStr)
        }
        if let currPrice = currItem["price"].int {
            cell.productPrice.text = "$" + String(currPrice) + "/day";
        }

        cell.productImage.contentMode = .scaleAspectFit;
        cell.productImage.layer.borderWidth = 1;
        cell.productDistance.text = currItem["distance"].string! + " mi";
        cell.backgroundColor = UIColor.white
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
        getData()
        loadData()
        reloadData()
    }
    
    override func viewDidLoad() {
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
        categories = ["shirt", "pant", "skirt", "shorts", "dress", "none"]
        sizes = ["XS", "S", "M", "L", "XL"]
        getData()
        loadData()
        reloadData()
        
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
    
    
    func initDropDowns() {
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont(name: "Alike-Regular", size: 17)!
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
        let capsCategories = ["Shirts", "Pants", "Skirts", "Shorts", "Dresses", "All items"]
        categoryDropDown.dataSource = capsCategories
        
        categoryDropDown.selectionAction = { [weak self] (index: Int, _: String) in
            if (index == 5) {
                categorySet = false
                self?.reloadData()
                self?.showingLabel.text = "Showing: All Items"
                self?.categoryButton.titleLabel!.text = "All items"
            } else {
                categorySet = true
                //print(index)
                currCategory = index
                self?.showingLabel.text = "Showing: " + capsCategories[index]
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

