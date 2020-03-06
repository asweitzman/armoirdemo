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

class ChatPreviewViewController: UIViewController {
    
    private let cellId = "chatPreviewCell"
    private var chats = [PreviewMessageModel]()
    let chatsDB = Database.database().reference().child("chats")
    let usersDB = Database.database().reference().child("users")
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatsDB.removeAllObservers()
    }
    
    func setup() {
        //set the delegates
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatPreviewCell.self, forCellReuseIdentifier: cellId)
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
    
    func loadChat(chatID: String) {
        let chatRef = chatsDB.child(chatID)
        chatRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot!) in
            let snapshotValue = snapshot.value as! [String : AnyObject]
            guard let senderHash = snapshotValue["sender"] as? String else {return}
            guard let senderName = snapshotValue["senderName"] as? String else {return}
            guard let receiverHash = snapshotValue["receiver"] as? String else {return}
            //for use in custom cells
            guard let item_id = snapshotValue["item_id"] else {return}
            guard let status = snapshotValue["status"] else {return}
            let isIncoming = (senderHash == Auth.auth().currentUser!.uid ? false : true)
            
            //@ALEX: PreviewMessageModel is in ChatPreviewCell.swift. It'll probably not be necessary when the custom tableview cell is implemented.
            let chatPreview = PreviewMessageModel.init(receiver: receiverHash, sender: senderName, isIncoming: isIncoming, name: chatID)
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
        self.performSegue(withIdentifier: "toChatsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatPreviewCell
       // cell.configure(with: chats[indexPath.row])
        cell.configure(with: chats[indexPath.row])
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
