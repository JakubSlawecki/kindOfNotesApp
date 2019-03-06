//
//  AddNoteViewController.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 22/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import UIKit


protocol AddNoteViewControllerDelegate: class {
    func noteDetailViewControllerDidCancel(_ controller: NoteDetailViewController)
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishAdding note: NoteItem)
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishEditind note: NoteItem)
}


class NoteDetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var switchButtonOutlet: UISwitch!
    
    var noteToEdit: NoteItem?
    var image: UIImage?
    var noteToEditImages = [UIImage]()
    weak var delegate: AddNoteViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchButtonOutlet.isOn = false
        
        if let note = noteToEdit {
            title = "Edit Note"
            titleTextField.text = note.noteTitle
            textTextField.text = note.noteText
            noteToEditImages.append(contentsOf: arrayOfStringsToArrayOfImages(array: note.noteImages))
            if note.isLoced == true {
                switchButtonOutlet.isOn = true
                passwordTextField.text = note.password
            } else {
                switchButtonOutlet.isOn = false
            }
            if noteToEditImages.count >= 6 {
                addPhotoButton.isEnabled = false
            }
            doneBarButton.isEnabled = true
        }
    }
    
    
    // MARK:- Actions
    
    
    @IBAction func cancel() {
        delegate?.noteDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let note = noteToEdit {
            configureTitleTextAndImage(note: note)
            
            if switchButtonOutlet.isOn == true {
                note.isLoced = true
                note.password = passwordTextField.text!
            } else if switchButtonOutlet.isOn == false {
                note.isLoced = false
                note.password = ""
            }
            delegate?.noteDetailViewController(self, didFinishEditind: note)
        } else {
            let note = NoteItem()
            configureTitleTextAndImage(note: note)
            
            if switchButtonOutlet.isOn == true {
                note.isLoced = true
                note.password = passwordTextField.text!
            }
            delegate?.noteDetailViewController(self, didFinishAdding: note)
        }
    }
    
    @IBAction func textField(_ sender: AnyObject) {
        self.view.endEditing(true);
    }
    
    @IBAction func chooseImageButton(_ sender: Any) {
        pickPhoto()
    }
    
    @IBAction func switchPassword(_ sender: UISwitch) {
        if (sender.isOn == true) {
            passwordTextField.isEnabled = true
        } else {
            passwordTextField.isEnabled = false
        }
    }
    
    func configureTitleTextAndImage(note: NoteItem) {
        note.noteTitle = titleTextField.text!
        note.noteText = textTextField.text!
        if let image = image {
            note.noteImages.append(convertImageToBase64(image: image))
        }
    }
    
    func configureCollectionViewCell(cell: CollectionViewCell, indexPath: IndexPath) {
        cell.imageView.image = noteToEditImages[indexPath.item]
        cell.imageView.layer.cornerRadius = 50.0
        cell.imageView.layer.borderWidth = 1.0
        cell.imageView.clipsToBounds = true
        cell.index = indexPath
        cell.delegate = self
    }
    
    
    // MARK:- CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noteToEditImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        configureCollectionViewCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController
        vc?.image = noteToEditImages[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    // MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
        return true
    }
}


extension NoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK:- Image Helper Methods
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    

    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func show(image: UIImage) {
        noteToEditImages.append(image)
        collection.reloadData()
    }
    
    
    // MARK:- Images to strings and strings to images
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    // Convert a base64 representation to a UIImage
    func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    func arrayOfStringsToArrayOfImages(array: [String]) -> [UIImage] {
        var newArray = [UIImage]()
        for i in array {
            let uiImage = convertBase64ToImage(imageString: i)
            newArray.append(uiImage)
        }
        return newArray
    }
    
    func arrayOfImagesToArrayOfStings(array: [UIImage]) -> [String] {
        var newArray = [String]()
        for i in array {
            let imageAsString = convertImageToBase64(image: i)
            newArray.append(imageAsString)
        }
        return newArray
    }
}


extension NoteDetailViewController: CollectionViewCellProtocol {
    func deleteData(index: Int) {
        noteToEditImages.remove(at: index)
        collection.reloadData()
        if let note = noteToEdit {
            note.noteImages.remove(at: index)
        }
    }
    
}
