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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = snapshotImage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ nameField: UITextField, _ urlField: UITextField, _ describtionField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        urlField.resignFirstResponder()
        describtionField.resignFirstResponder()
        return true
    }
    
    @IBAction func uploadImageAction() {
        print("Upload")
        if let image = imageView!.image{
            ImageUploader.uploadImage(name: nameField.text!, image:image, description: describtionField.text!, youtubeUrl: urlField.text!)
        }
    }
}
