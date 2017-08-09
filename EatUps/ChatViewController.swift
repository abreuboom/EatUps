

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


import UIKit
import Firebase
import AlamofireImage
import Photos
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Properties
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var keyboardLine: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    var items = [Message]()
    let barHeight: CGFloat = 110
    let imagePicker = UIImagePickerController()
    var currentUser = User.current
    var selectedUser: User?
    var eatup: EatUp?
    let actionBubbles = ["📷", "🌁", "👀 What do you see?", "🕺 Where are you standing?"]
//    let actionBubblesSizes = [(, "🌁", "👀 What do you see?", "🕺 Where are you standing?"]
    
    @IBOutlet weak var eatupAtParent: UIView!
    @IBOutlet var eatupAtView: EatupAtView!

    
    override func viewWillAppear(_ animated: Bool) {
        eatupAtView.layer.cornerRadius = eatupAtView.frame.width/5
        eatupAtView.dropShadow()
        eatupAtView.center = eatupAtParent.center
        
        eatupAtView.place = eatup?.place
        let size = eatupAtView.eatupAtLabel.sizeThatFits(self.view.bounds.size)
        eatupAtView.eatupAtLabel.frame.size = size
        eatupAtView.frame = CGRect.init(x: eatupAtParent.center.x - (eatupAtView.eatupAtLabel.bounds.size.width + 32)/2, y: eatupAtParent.center.y - eatupAtView.bounds.size.height/2 - 60, width: eatupAtView.eatupAtLabel.bounds.size.width + 32, height: eatupAtView.bounds.size.height)
        eatupAtParent.bringSubview(toFront: eatupAtView)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        eatupAtView.reset()
        eatupAtView.removeFromSuperview()
    }
    
    
    //MARK: Methods
    func customization() {
        eatupAtParent.addSubview(eatupAtView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationController?.isNavigationBarHidden = true
        doneButton.setTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
    }
    
    func doneButtonAction () {
        self.performSegue(withIdentifier: "chatToRatingSegue", sender: nil)
    }
    
    //Downloads messages
    func fetchData() {
        Message.downloadAllMessages(forUserID: (currentUser?.id)!, eatUpID: (eatup?.id)!, completion: {[weak weakSelf = self] (message) in
            weakSelf?.items.append(message)
            weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
            DispatchQueue.main.async {
                if let state = weakSelf?.items.isEmpty, state == false {
                    weakSelf?.tableView.reloadData()
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })    }
    
    //Hides current viewcontroller
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970))
        Message.send(message: message, toID: (selectedUser?.id)!, eatUpID: (eatup?.id)!, completion: {(_) in
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionBubbleCell", for: indexPath) as! ActionBubbleCell
        let buttonTitle = actionBubbles[indexPath.item]
        if buttonTitle == "📷" {
            cell.actionBubbleButton.setImage(UIImage(named: "Camera") , for: .normal)
            cell.actionBubbleButton.addTarget(self, action: #selector(selectCamera(_:)), for: .touchUpInside)
        }
        else if buttonTitle == "🌁" {
            cell.actionBubbleButton.setImage(UIImage(named: "Photos") , for: .normal)
            cell.actionBubbleButton.addTarget(self, action: #selector(selectGallery(_:)), for: .touchUpInside)
        }
        else if buttonTitle == "👀 What do you see?" {
            cell.actionBubbleButton.setImage(UIImage(named: "see") , for: .normal)
            cell.actionBubbleButton.addTarget(self, action: #selector(askedWhatSee), for: .touchUpInside)
        }
        else if buttonTitle == "🕺 Where are you standing?" {
            cell.actionBubbleButton.setImage(UIImage(named: "stand") , for: .normal)
            cell.actionBubbleButton.addTarget(self, action: #selector(askedWhereStand), for: .touchUpInside)
        }
        cell.actionBubbleButton.sizeToFit()
    
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionBubbles.count
    }
    
    func selectGallery(_ sender: Any) {
        collectionView.isHidden = true
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func selectCamera(_ sender: UIButton) {
        collectionView.isHidden = true
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        if collectionView.isHidden == false {
            collectionView.isHidden = true
            keyboardLine.frame = keyboardLine.frame.offsetBy( dx: 0, dy: 50 )
        }
        else if collectionView.isHidden == true {
            collectionView.isHidden = false
            keyboardLine.frame = keyboardLine.frame.offsetBy( dx: 0, dy: -50 )
        }
    }

    
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    
    
    //MARK: NotificationCenter handlers
    func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .actionBubble:
                cell.message.text = self.items[indexPath.row].content as! String
            case .actionResponse:
                cell.actionButton.setTitle("🕺", for: .normal)
                cell.actionButton.isHidden = false
                cell.message.text = self.items[indexPath.row].content as! String
                if cell.message.text == "Here's my location!" {
                    cell.actionButton.addTarget(self, action: #selector(onSendLocation), for: .touchUpInside)
                }
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.af_setImage(withURL: (selectedUser?.profilePhotoUrl)!)
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .actionBubble:
                cell.message.text = self.items[indexPath.row].content as! String
                cell.actionButton.isHidden = false
                if cell.message.text == "Where are you standing?" {
                    cell.actionButton.setTitle("🕺", for: .normal)
                    cell.actionButton.addTarget(self, action: #selector(onWhereStand), for: .touchUpInside)
                }
                else if cell.message.text == "What do you see?" {
                    cell.actionButton.setTitle("👀", for: .normal)
                    cell.actionButton.addTarget(self, action: #selector(onWhatSee), for: .touchUpInside)
                }
            case .actionResponse:
                cell.actionButton.setTitle("🕺", for: .normal)
                cell.actionButton.isHidden = false
                cell.message.text = self.items[indexPath.row].content as! String
                if cell.message.text == "Here's my location!" {
                    cell.actionButton.addTarget(self, action: #selector(onSendLocation), for: .touchUpInside)
                }
            }
            return cell
        }
    }
    
    // MARK: Action bubble response functions
    func onWhereStand() {
        composeMessage(type: .actionResponse, content: "Here's my location!")
    }
    
    func onWhatSee() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func onSendLocation () {
        self.performSegue(withIdentifier: "chatToMapSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type {
        case .photo:
            if let photo = self.items[indexPath.row].image {
                let info = ["viewType" : ShowExtraView.preview, "pic": photo] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
                self.inputAccessoryView?.isHidden = true
            }
            default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func didActionBubble(content: String?) {
        if let content = content {
            composeMessage(type: .actionBubble, content: content)
        }
    }
    
    func askedWhatSee() {
        didActionBubble(content: "What do you see?")
    }
    
    func askedWhereStand() {
        didActionBubble(content: "Where are you standing?")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatToLocationSegue" {
            let ShareLocationViewController = segue.destination as! ShareLocationViewController
            ShareLocationViewController.selectedUser = selectedUser
            ShareLocationViewController.eatupPlace = eatup?.place
        }
        else if segue.identifier == "chatToRatingSegue" {
            let RatingViewController = segue.destination as! RatingViewController
            RatingViewController.selectedUser = selectedUser
            RatingViewController.eatupId = eatup?.id
        }
    }
    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
}



