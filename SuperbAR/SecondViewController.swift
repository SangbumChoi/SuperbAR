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
    @IBOutlet weak var textField: UITextField!{
        didSet {
            textField.delegate = self
        }
    }
    
    var snapshotImage: UIImage? = nil
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = snapshotImage
        textLabel?.text = text
        print(snapshotImage)
        print(text)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func uploadImageAction() {
        print("upload image")
        print(imageView?.image)
        if let image = imageView!.image{
            ImageUploader.uploadImage(key: "key", image:image)
        }
    }
}
