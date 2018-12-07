//
//  ProductBrowseViewController.swift
//  Armoir
//
//  Created by alex weitzman on 11/29/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit
import DropDown

var clickedIndex:Int = Int()
var productImageURLs:[String] = [String]()

var otherUsers:[a_User] = [];


class ProductBrowseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var fullArray: [Item] = [];
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryDropDown: UILabel!
    
    @IBOutlet weak var Sortby: UILabel!
    
    @IBOutlet weak var Filter: UILabel!
    
    func loadData() {
        /*
        var numImages = 10
    
        let imageURL = "https://i.imgur.com/JOPiokr.png"
        
        while(numImages > 0) {
            productImageURLs.append(imageURL)
            numImages -= 1
        }*/
        
        var myStructArray:[a_User] = [];
        do {
            try myStructArray = JSONDecoder().decode([a_User].self, from: json);
        }
        catch {
            print("array didn't work");
        }
        for stru in myStructArray {
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
    
    @IBOutlet weak var showingLabel: UILabel!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return array.count
        //return productImageURLs.count
        return fullArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! ProductCell
        
        
        let i = fullArray[indexPath.row]
        
        cell.productImage.image = UIImage(named: i.imgURL);
        cell.productImage.contentMode = .scaleToFill;
        cell.productImage.layer.borderWidth = 1;
        cell.productPrice.text = "$" + String(i.price) + "/day";
        cell.productDistance.text = "0.8 mi"
        cell.backgroundColor = UIColor.white
        return cell
        
        
        
        /*
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
 
        if let imgURL = URL(string: productImageURLs[indexPath.row]) {
            
            URLSession.shared.dataTask(with: imgURL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let image = UIImage(data: data!)
            
                DispatchQueue.main.async {
                    cell.productImage.image = image
                }
            }).resume()
        }

       /* if let imgURL = URL(string: "https://i.imgur.com/JOPiokr.png") {
            
            URLSession.shared.dataTask(with: imgURL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    cell.productImage.image = image
                }
            }).resume()
        }*/
        
        //cell.productImage.image = UIImage(named: "NewsScreenshot")
        cell.productPrice.text = "$5/day"
        //cell.productDistance.text = "1.2 mi"
        */
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        let itemSize = (UIScreen.main.bounds.width / 2) - 3
        let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: itemSize, height: itemSize*1.3)
        
        layout.minimumInteritemSpacing = 1
        //layout.minimumLineSpacing = 7
        
        myCollectionView.collectionViewLayout = layout
    }
    
    /*func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        clickedIndex = indexPath.row
        self.performSegue(withIdentifier: "toItemDetail", sender: self)
    }*/
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = fullArray[indexPath.row].item_id;
        
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

