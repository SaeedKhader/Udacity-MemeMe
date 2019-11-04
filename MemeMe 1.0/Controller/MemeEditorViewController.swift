//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 26/09/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: UI Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var topSafeArea: UIView!
    
    var cropView: CropView!
    var fontView: FontView!
    
    
    // MARK: properties
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5
    ]
    
    var isCropModeOn: Bool = false
    
    var orginalImage: UIImage?
    
    var activeTextField: UITextField!

    var croppedImageXFactor: CGFloat?
    var croppedImageYFactor: CGFloat?
    var croppedImageWidthFactor: CGFloat?
    var croppedImageHeightFactor: CGFloat?
    
    
    // MARK: View Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCropView), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotificaiton()
    }
    
    
    // MARK: UI Functions
    
    @IBAction func pickAnImage() {
        chooseAnImage(sourceType: .photoLibrary)
    }
    
    @IBAction func takeAnImage() {
        chooseAnImage(sourceType: .camera)
    }
    
    @IBAction func shareMeme() {
        
        if let activeTextField = activeTextField {
            activeTextField.resignFirstResponder()
        }
        
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type,completed,items,error) in
            if ( completed ) {
                self.save()
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func toggleCropMode() {

        isCropModeOn.toggle()
        
        if !isCropModeOn {
            crop()
            cropView.userInteractive(bool: false)
            cropButton.layer.borderWidth = 0
        } else {
            setUpCropView()
            cropView.userInteractive(bool: true)
            cropButton.layer.borderWidth = 1
            cropButton.layer.borderColor = UIColor.white.cgColor
        }

        UIView.animate(withDuration: 0.1, animations: {
           
            if self.isCropModeOn {
                self.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } else {
                self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        })
        
        cropView.isHidden = !isCropModeOn
        topTextField.isHidden = isCropModeOn
        bottomTextField.isHidden = isCropModeOn
        shareButton.isEnabled = !isCropModeOn
        libraryButton.isEnabled = !isCropModeOn
        cameraButton.isEnabled = !isCropModeOn && UIImagePickerController.isSourceTypeAvailable(.camera)
           
    }
    
    // MARK: functions
    
    func save() {
        _ = Meme(topText: topTextField.text!, bottemText: bottomTextField.text!, orginalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    func chooseAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController =  UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        hideElements(hide: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideElements(hide: false)
        
        return memedImage
    }
    
    func hideElements(hide: Bool){
        navBar.isHidden = hide
        toolBar.isHidden = hide
        cropButton.isHidden = hide
        topSafeArea.isHidden = hide
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            orginalImage = image
            imageView.image = image
            shareButton.isEnabled = true
            cropButton.isEnabled = true
        }
        
    }
    
    func crop() {
        
        let xFactor = orginalImage!.size.width / cropView.frame.width
        let yFactor = orginalImage!.size.height / cropView.frame.height
        let width = cropView.cropAreaView.frame.width * xFactor
        let x = cropView.cropAreaView.frame.minX * xFactor
        let height = cropView.cropAreaView.frame.height * yFactor
        let y = cropView.cropAreaView.frame.minY * yFactor
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let imgOrientation = orginalImage!.imageOrientation
        let imgScale = orginalImage!.scale
        let cgImage = orginalImage!.cgImage
        
        let croppedCGImage = cgImage!.cropping(to: frame)
        
        let coreImage = CIImage(cgImage: croppedCGImage!)
        
        let ciContext = CIContext(options: nil)
        
        let filteredImageRef = ciContext.createCGImage(coreImage, from: coreImage.extent)
        
        let croppedImage = UIImage(cgImage: filteredImageRef!, scale: imgScale, orientation: imgOrientation)
        
        imageView.image = croppedImage
        
        croppedImageWidthFactor = cropView.cropAreaView.frame.width / cropView.frame.width
        croppedImageHeightFactor = cropView.cropAreaView.frame.height / cropView.frame.height
        croppedImageXFactor = cropView.cropAreaView.frame.minX / cropView.frame.width
        croppedImageYFactor = cropView.cropAreaView.frame.minY / cropView.frame.height
    }
    
    
    func setUpCropView() {
        
        if let cropView = cropView {
            cropView.removeFromSuperview()
        }
        
        cropView = CropView()
        
        imageView.image = orginalImage
        
        cropView.frame = cropView.getImageFrame(imageViewSize: imageView.frame.size, imageSize: imageView.image!.size)
        
        imageView.addSubview(cropView)
        
        let x = cropView.frame.width * (croppedImageXFactor ?? 0)
        let y = cropView.frame.height * (croppedImageYFactor ?? 0)
        let width = cropView.frame.width * (croppedImageWidthFactor ?? 1)
        let height = cropView.frame.height * (croppedImageHeightFactor ?? 1)
        
        cropView.setUpCropView(x: x, y: y, width: width, height: height)
        
        cropView.setUpLayout()
        
        cropView.isHidden = true
    }
    
    @objc func updateCropView() {
        if isCropModeOn {
            imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            setUpCropView()
            imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            cropView.isHidden = false
        }
    }
    
    // MARK: Keyboard Functions
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotificaiton() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let safeArea = view.frame.height - getKeyboardHeight(notification) - fontView.frame.height
        let textMaxY = activeTextField!.frame.maxY
        if ( textMaxY > safeArea ) {
            view.frame.origin.y -= ( textMaxY - safeArea ) + toolBar.frame.height + 10
            fontView.bottomLayout?.constant = -getKeyboardHeight(notification) + ( textMaxY - safeArea ) + toolBar.frame.height
        } else if view.frame.origin.y == 0  {
            fontView.bottomLayout?.constant = -getKeyboardHeight(notification) - 10
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

}
