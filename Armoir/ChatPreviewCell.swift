//
//  ChatPreviewCell.swift
//  Armoir
//
//  Created by Ellen Roper on 2/26/20.
//  Copyright © 2020 CS147. All rights reserved.
//

import UIKit
import Foundation

class ChatPreviewCell: UITableViewCell {
    //@IBOutlet weak var senderLabel: UILabel!
    //@IBOutlet weak var receiverLabel: UILabel!
    
    let senderLabel = UILabel()
    let messageBgView = UIView()
    
    var isIncoming: Bool = false {
        didSet {
            messageBgView.backgroundColor = isIncoming ? UIColor.white : #colorLiteral(red: 0.8823529412, green: 0.968627451, blue: 0.7921568627, alpha: 1)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(messageBgView)
    addSubview(senderLabel)
    messageBgView.translatesAutoresizingMaskIntoConstraints = false
    messageBgView.layer.cornerRadius = 7
    senderLabel.numberOfLines = 0
    senderLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // set constraints for the message and the background view
    let constraints = [
        senderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
        senderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        
        messageBgView.topAnchor.constraint(equalTo: senderLabel.topAnchor, constant: -16),
        messageBgView.leadingAnchor.constraint(equalTo: senderLabel.leadingAnchor, constant: -16),
        messageBgView.bottomAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 16),
        messageBgView.trailingAnchor.constraint(equalTo: senderLabel.trailingAnchor, constant: 16)
    ]
            NSLayoutConstraint.activate(constraints)

            selectionStyle = .none
            backgroundColor = .clear
        }
           required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
            }
            
            // what we will call from our tableview method
            func configure(with model: PreviewMessageModel) {
                    let sender = model.senderName
                    // align to the left
                    let nameAttributes = [
                        NSAttributedString.Key.foregroundColor : UIColor.orange,
                        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)
                        ] as [NSAttributedString.Key : Any]
                    // sender name at top, message at the next line
                    let senderName = NSMutableAttributedString(string: sender + "\n", attributes: nameAttributes)
                    let receiver = NSMutableAttributedString(string: model.receiverName)
                    senderName.append(receiver)
                    senderLabel.attributedText = senderName
                    senderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
                    senderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = false
            }
        }

struct PreviewMessageModel {
    let receiverName: String
    let senderName: String
    let isIncoming: Bool
}
