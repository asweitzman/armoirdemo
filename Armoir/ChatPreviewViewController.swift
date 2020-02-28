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
    
    func getMessages() {
        
        chatsDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            guard let sender = snapshotValue["senderName"], let receiver = snapshotValue["receiverName"] else {return}
            print("here: ")
            print(sender)
            let isIncoming = (receiver == Auth.auth().currentUser?.displayName ? false : true)
            let chatPreview = PreviewMessageModel.init(receiverName: receiver, senderName: sender, isIncoming: isIncoming)
            self.addNewRow(with: chatPreview)
        }
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

