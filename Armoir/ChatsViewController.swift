//
//  ChatsViewController.swift
//  Armoir
//
//  Created by Ellen Roper on 2/24/20.
//  Copyright © 2020 CS147. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ChatsViewController: UIViewController {
    //chatcell identifier
    private let cellId = "chatCell"
    private var messages = [MessageModel]()
    let messageDB = Database.database().reference().child("Messages")
    let chatsDB = Database.database().reference().child("chats")
    var frameView: UIView!
    
    //MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemImage: UIImageView!


    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        self.messageTextField.returnKeyType = UIReturnKeyType.send
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setup()
        for i in allItems {
            if (i.item_id == currItem) {
                itemName.text = i.name
                let imageRef = storageRef.child("images/" + String(i.image))
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("image url error")
                    } else {
                        let data = try? Data(contentsOf: url!)
                        let image = UIImage(data: data!)
                        let thumb1 = image?.resized(By: 0.2)
                        self.itemImage.image = thumb1
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageDB.removeAllObservers()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func setup() {
        //set the delegates
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        // do not show separators and set the background to gray-ish
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        hideKeyboardOnTap()
        loadMessages()
    }
    
    
    // call this to listen to database changes and add it into our tableview
    func loadMessages() {
        print("current chat: " + currChat)
        let chatRef = Database.database().reference().child("chats").child(currChat).child("messages")
        chatRef.queryOrdered(byChild: "timestamp").observe(.childAdded) { (snapshot) in
               let name = snapshot.key
               print(name)
            let snapshotValue = snapshot.value as! [String: AnyObject]
            guard let senderHash = snapshotValue["senderHash"] as? String, let content = snapshotValue["content"]  as? String else {return}
               print("here: ")
               print(senderHash)
            guard let senderName = snapshotValue["senderName"]  as? String else {return}
            let isIncoming = (senderHash as! String == Auth.auth().currentUser!.uid ? false : true)
            let chatPreview = MessageModel.init(message: content, senderName: senderName, isIncoming: isIncoming)
               self.addNewRow(with: chatPreview)
           }
       }
    
    // function to add our cells with animation
    
    func addNewRow(with chatMessage: MessageModel) {
        self.tableView.beginUpdates()
        self.messages.append(chatMessage)
        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
    }
    
    
    
    //MARK: Buttons
    
    @IBAction func sendButtonDidTap(_ sender: Any) {
        // return if message does not exist
        let chatRef = Database.database().reference().child("chats").child(currChat).child("messages")
        guard let message = messageTextField.text else {return}
        if message == "" {
            return
        }
    
        //stop editing the message
        messageTextField.endEditing(true)
        // disable the buttons to avoid complication for simplicity
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let timestamp = NSDate().timeIntervalSince1970
        let messageID = self.randomString(length: 20)
        let chatMessageDict = ["senderName": Auth.auth().currentUser?.displayName, "content" : message, "timestamp": timestamp, "senderHash": Auth.auth().currentUser!.uid, "messageID" : messageID] as [String : Any]
        chatRef.child(messageID).setValue(chatMessageDict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                print("sent message")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text?.removeAll()
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "New message from " + String(Auth.auth().currentUser?.displayName ?? "")
        content.body = message
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (5), repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("error when sending message notification")
           } else {
                print("notification successfully scheduled")
            }
        }
    }
    
    
}

// MARK: - TableView Delegates

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

//MARK: - TextField Delegates

extension ChatsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
        //return true
    }
    //handle when keyboard is shown and hidden
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /*UIView.animate(withDuration: 0.3) {
            self.textFieldViewHeight.constant = 308
            self.view.layoutIfNeeded()
        }*/
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        /*UIView.animate(withDuration: 0.3) {
            self.textFieldViewHeight.constant = 50
            self.view.layoutIfNeeded()
        }*/

    }
}

extension ChatsViewController {
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
        if let navController = self.navigationController {
            navController.view.endEditing(true)
        }
    }
}
