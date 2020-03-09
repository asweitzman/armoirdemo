//
//  ChatPreviewViewController.swift
//  Armoir
//
//  Created by Ellen Roper on 2/26/20.
//  Copyright © 2020 CS147. All rights reserved.
//
import Foundation
import UIKit
import Firebase

var currItemID = 0
var currSender = ""
var currSenderID = ""
var currReceiver = ""
var isIncoming = Bool()

class MessagePreviewCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var senderIcon: UIImageView!
    
    //    var isIncoming: Bool = false {
//        didSet {
//            messageBgView.backgroundColor = isIncoming ? UIColor.white : #colorLiteral(red: 0.8622178435, green: 0.8425275087, blue: 0.8211465478, alpha: 1)
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
     }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(with model: ChatPreviewViewController.PreviewMessageModel) {
            let sender = model.senderName
            // align to the left
            let nameAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.orange,
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)
                ] as [NSAttributedString.Key : Any]
            // sender name at top, message at the next line
            let senderName = NSMutableAttributedString(string: sender + "\n", attributes: nameAttributes)
            let receiver = NSMutableAttributedString(string: model.receiver)
            senderName.append(receiver)
        
            print(senderName)
            print(model.name)
            print(model.receiver)
        
//            let isIncoming = model.isIncoming
//            if isIncoming {
//                senderLabel.attributedText = senderName
//            } else {
//                for user in otherUsers {
//                    if (user.user_ID == model.receiver) {
//                        senderLabel.attributedText = user.display_name
//                    }
//                }
//
//            }

        
            for item in allItems {
                if model.item_id == item.item_id {
                    
                    let ref = Database.database().reference().child("users")
                    ref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
                        let snapshotValue = snapshot.value as! [String : AnyObject]
                        let ownerVal = snapshotValue[item.owner] as! [String: AnyObject]
                        let usernameString = ownerVal["display_name"] as! String
                        if model.isIncoming {
                            self.senderLabel.attributedText = senderName
                            print("sendeR:")
                            print(model.sender)
                            let ownerVal = snapshotValue[model.sender] as! [String: AnyObject]
                            let imageUrl = ownerVal["profPic"] as! String
                            let profRef = storageRef.child("images/\(imageUrl)")
                            profRef.downloadURL { url, error in
                            if let error = error {
                                print("image download error")
                            } else {
                                let data = try? Data(contentsOf: url!)
                                let image = try? UIImage(data: data!)
                                self.senderIcon.image = image as! UIImage;
                            }
                            }
                                
                        } else {
                            let otherPerson = NSMutableAttributedString(string: usernameString + "\n", attributes: nameAttributes)
                            self.senderLabel.attributedText = otherPerson
                            let imageUrl = ownerVal["profPic"] as! String
                            let profRef = storageRef.child("images/\(imageUrl)")
                            profRef.downloadURL { url, error in
                              if let error = error {
                                print("image download error")
                              } else {
                                let data = try? Data(contentsOf: url!)
                                let image = try? UIImage(data: data!)
                                self.senderIcon.image = image as! UIImage;
                              }
                            }
                        }
                    }
                    
                    
                    
                    let imageRef = storageRef.child("images/" + String(item.image))
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("image url error")
                        } else {
                            let data = try? Data(contentsOf: url!)
                            let image = try? UIImage(data: data!)
                            self.itemImage.image = image as! UIImage;
                        }
                    }
                }
            }
        }
    }
//            senderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
//            senderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = false
        



class ChatPreviewViewController: UIViewController {
    

    private let cellId = "messagePreviewCell"
    private var chats = [PreviewMessageModel]()
    let chatsDB = Database.database().reference().child("chats")
    let usersDB = Database.database().reference().child("users")
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func getNewestMessage(currChat: String) -> String {
     print("current chat: " + currChat)
     var newest = ""
     var newestMessages:[String:String] = [String:String]()
     let chatRef = Database.database().reference().child("chats").child(currChat).child("messages")
     chatRef.queryOrdered(byChild: "timestamp").observe(.childAdded) { (snapshot) in
         let snapshotValue = snapshot.value as! [String: AnyObject]
        guard let content = snapshotValue["content"]  as? String else { return }
        newest = content
        print("content before: ")
        print(newest)
        }
        return newest
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatsDB.removeAllObservers()
    }
    
    func setup() {
        //set the delegates
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(ChatPreviewCell.self, forCellReuseIdentifier: cellId)
    
        
        // do not show separators and set the background to gray-ish
        //tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        getMessages()
        // extension of this can be found in the ViewController.swift
        // basically hides the keyboard when tapping anywhere
        //hideKeyboardOnTap()
    }
    
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "toChatsSegue"
            //let destination = segue.destination as? ChatsViewController,
           // let index = tableView.indexPathForSelectedRow?.row
        {
            self.performSegue(withIdentifier: "toChatsSegue", sender: self)
            return
           // destination.blogName = swiftBlogs[index]
       }
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    struct PreviewMessageModel {
        let receiver: String
        var receiverName: String
        let sender: String
        let senderName: String
        let isIncoming: Bool
        let name: String
        let item_id: Int
    }
    
    func loadChat(chatID: String) {
        let chatRef = chatsDB.child(chatID)
        chatRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            guard let senderHash = snapshotValue["sender"] as? String else {return}
            guard let senderName = snapshotValue["senderName"] as? String else {return}
            guard let receiverHash = snapshotValue["receiver"] as? String else {return}
            //for use in custom cells
            guard let item_id = snapshotValue["item_id"] as? Int else {return}
            guard let status = snapshotValue["status"] else {return}
            
            let isIncoming = (senderHash == Auth.auth().currentUser!.uid ? false : true)
            
//            var receiverName = ""
//            for item in allItems {
//                if item_id == item.item_id {
//                let ref = Database.database().reference().child("users")
//                ref.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
//                    let snapshotValue = snapshot.value as! [String : AnyObject]
//                    let ownerVal = snapshotValue[item.owner] as! [String: AnyObject]
//                    let usernameString = ownerVal["display_name"] as! String
//                    receiverName = usernameString
//                    }
//                }
//            }
            
            //@ALEX: PreviewMessageModel is in ChatPreviewCell.swift. It'll probably not be necessary when the custom tableview cell is implemented.
            let chatPreview = PreviewMessageModel.init(receiver: receiverHash, receiverName: "", sender: senderHash, senderName: senderName, isIncoming: isIncoming, name: chatID, item_id: item_id)
            self.addNewRow(with: chatPreview)
        }
    }
    
    
    func getMessages() {
        let target = Database.database().reference().child("users").child(currentUser!.uid)
        target.child("chats").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists(){
                target.child("chats").setValue("")
            }
        })
        let userDB = Database.database().reference().child("users").child(currentUser!.uid).child("chats")
        userDB.observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
               print("– – – Data was not found – – –")

            } else {
                for chat_child in (snapshot.children) {

                    let user_snap = chat_child as! DataSnapshot
                    let chatID = user_snap.value as! String
                    self.loadChat(chatID: chatID)
                }
            }
        })
    }
    
    // function to add our cells with animation
    
    func addNewRow(with chatPreview: PreviewMessageModel) {
        self.tableView.beginUpdates()
        self.chats.append(chatPreview)
        let indexPath = IndexPath(row: self.chats.count-1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
    }
}

extension ChatPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("tapped")
        let current = chats[indexPath.row]
        currChat = current.name
        currItemID = current.item_id
        currSender = current.senderName
        currSenderID = current.sender
        currReceiver = current.receiver
        isIncoming = current.isIncoming
        
        self.performSegue(withIdentifier: "toChatsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessagePreviewCell
        
        cell.senderIcon.layer.cornerRadius = cell.senderIcon.frame.size.width / 2;
        cell.configure(with: chats[indexPath.row])
        
//        let newestMessage = cell.getNewestMessage(currChat: chats[indexPath.row].name)
//        print("newest: ")
//        print(newestMessage)
//        cell.messageLabel.text = newestMessage
//        cell.configure(with: chats[indexPath.row])
        
        
        /*let currentChat = chats[indexPath.row]
        let nameAttributes = [
                       NSAttributedString.Key.foregroundColor : UIColor.orange,
                       NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)
                       ] as [NSAttributedString.Key : Any]
        let sender = currentChat.senderName
        let senderName = NSMutableAttributedString(string: sender! + "\n", attributes: nameAttributes)
        print(senderName)
        print(currentChat.receiverName)
        cell.senderLabel.text = sender
        cell.receiverLabel.text = currentChat.receiverName*/
        return cell
    }
    
}
