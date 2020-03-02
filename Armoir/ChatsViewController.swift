//
//  ChatsViewController.swift
//  Armoir
//
//  Created by Ellen Roper on 2/24/20.
//  Copyright © 2020 CS147. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController {
    
    //chatcell identifier
    private let cellId = "chatCell"
    private var messages = [MessageModel]()
    let messageDB = Database.database().reference().child("Messages")
    let chatMessageDB = Database.database().reference().child("chatMessages")
    var frameView: UIView!
    
    //MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!


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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        self.messageTextField.returnKeyType = UIReturnKeyType.send
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setup()
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
        
        getMessages()
        // extension of this can be found in the ViewController.swift
        // basically hides the keyboard when tapping anywhere
        hideKeyboardOnTap()
    }
    
    // call this to listen to database changes and add it into our tableview
    
    func getMessages() {
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            guard let message = snapshotValue["message"], let sender = snapshotValue["sender"] else {return}
            let isIncoming = (sender == Auth.auth().currentUser?.displayName ? false : true)
            let chatMessage = MessageModel.init(message: message, sender: sender, isIncoming: isIncoming)
            self.addNewRow(with: chatMessage)
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
        guard let message = messageTextField.text else {return}
        if message == "" {
            return
        }
    
        //stop editing the message
        messageTextField.endEditing(true)
        // disable the buttons to avoid complication for simplicity
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDict = ["sender": Auth.auth().currentUser?.displayName, "message" : message]
        let chatMessageDict = ["sender": Auth.auth().currentUser?.displayName, "message" : message]
        chatMessageDB.childByAutoId().setValue(chatMessageDict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                print("umm")
            }
        }
        
        messageDB.childByAutoId().setValue(messageDict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                print("Message sent!")
                //enable the buttons and remove the text
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text?.removeAll()
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
