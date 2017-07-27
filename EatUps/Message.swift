//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit
import Firebase

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var content: Any
    var timestamp: Int
    private var toID: String?
    private var fromID: String?
    
    //MARK: Methods
    class func downloadAllMessages(forUserID: String, eatUpID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("eatups").child(eatUpID).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("conversation") {
                    let data = snapshot.value as! [String: Any]
                    let location = data["conversation"] as! String
                Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromID"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            if fromID == currentUserID {
                                let message = Message.init(content: content, owner: .receiver, timestamp: timestamp)
                                completion(message)
                            } else {
                                let message = Message.init(content: content, owner: .sender, timestamp: timestamp)
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    class func send(message: Message, toID: String, eatUpID: String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let values = ["content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp]
            Message.uploadMessage(withValues: values, toID: toID, eatUpID: eatUpID, completion: { (status) in
                completion(status)
            })
        }
    }
    
    
    class func uploadMessage(withValues: [String: Any], toID: String, eatUpID: String, completion: @escaping (Bool) -> Swift.Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("eatups").child(eatUpID).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("conversation") {
                    let data = snapshot.value as! [String: Any]
                    let location = data["conversation"] as! String
                    Database.database().reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["conversation": reference.parent!.key]
                        Database.database().reference().child("eatups").child(eatUpID).updateChildValues(data)
                        completion(true)
                    })
                }
            })
        }
    }
    
    
    //MARK: Inits
    init(content: Any, owner: MessageOwner, timestamp: Int) {
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
    }
}
