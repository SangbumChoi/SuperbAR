//
//  SecondViewController.swift
//  SuperbAR
//
//  Created by Sangbum Choi on 2022/04/30.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import UIKit


class SecondViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var nameField: UITextField!{
        didSet {
            nameField.delegate = self
        }
    }
    @IBOutlet weak var urlField: UITextField!{
        didSet {
            urlField.delegate = self
        }
    }
    @IBOutlet weak var describtionField: UITextField!{
        didSet {
            describtionField.delegate = self
        }
    }
    @IBOutlet weak var uploadButton: UIButton!
    
    var snapshotImage: UIImage? = nil
    
    var keyboardIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = snapshotImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        keyboardIsShown = false
    }
    
    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillShow(_ noti: NSNotification){
        // 키보드의 높이만큼 화면을 올려준다.
        if keyboardIsShown == false {
            if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y -= (keyboardHeight)
                }
            }
            keyboardIsShown = true
    }
    
    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillHide(_ noti: NSNotification){
        // 키보드의 높이만큼 화면을 내려준다.
        if keyboardIsShown == true {
            if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y += (keyboardHeight)
                }
            }
            keyboardIsShown = false
    }

    func textFieldShouldReturn(_ nameField: UITextField, _ urlField: UITextField, _ describtionField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        urlField.resignFirstResponder()
        describtionField.resignFirstResponder()

        return true
    }
    
    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil) }
    
    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
    // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil) }

    @IBAction func uploadImageAction() {
        print("Upload")
        if let image = imageView!.image{
            ImageUploader.uploadImage(name: nameField.text!, image:image, description: describtionField.text!, youtubeUrl: urlField.text!)
        }
    }
}
