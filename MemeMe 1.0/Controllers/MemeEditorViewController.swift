//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 26/09/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - UI Properties
    
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
    
    
    // MARK: - Properties
    
    var isCropModeOn: Bool = false
    
    var orginalImage: UIImage?
    
    var activeTextField: UITextField!

    var croppedImageXFactor: CGFloat?
    var croppedImageYFactor: CGFloat?
    var croppedImageWidthFactor: CGFloat?
    var croppedImageHeightFactor: CGFloat?
    
    var isNewMeme: Bool = true
    var memeToEdit: Meme?
    var memeToEditIndex: IndexPath?
    
    
    // MARK: - View Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFieldStyle(toTextField: topTextField)
        setUpTextFieldStyle(toTextField: bottomTextField)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        prepareMemeToEdit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCropView), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotificaiton()
    }
    
    
    func prepareMemeToEdit() {
        if let meme = memeToEdit {
            topTextField.text = meme.topText
            topTextField.defaultTextAttributes = meme.topTextAttributes
            bottomTextField.text = meme.bottemText
            bottomTextField.defaultTextAttributes = meme.bottomTextAttributes
            orginalImage = meme.orginalImage
            imageView.image = meme.croppedImage
            croppedImageXFactor = meme.croppedImageXFactor
            croppedImageYFactor = meme.croppedImageYFactor
            croppedImageWidthFactor = meme.croppedImageWidthFactor
            croppedImageHeightFactor = meme.croppedImageHeightFactor
            cropButton.isEnabled = true
            shareButton.isEnabled = true
        }
    }
    
    
    // MARK: - TextField Styling
    
    func setUpTextFieldStyle(toTextField textField: UITextField) {
        textField.defaultTextAttributes = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Impact", size: 40)!,
            .strokeWidth: -5
        ]
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
    }
    
    
    // MARK: - Image Picking
    
    @IBAction func pickAnImage() {
        chooseAnImage(sourceType: .photoLibrary)
    }
    
    @IBAction func takeAnImage() {
        chooseAnImage(sourceType: .camera)
    }
    
    func chooseAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController =  UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            orginalImage = resizeImageIfNeeded(image: image)
            imageView.image = orginalImage
            shareButton.isEnabled = true
            cropButton.isEnabled = true
        }
        
    }
    
    func resizeImageIfNeeded(image: UIImage) -> UIImage {
        let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
        let imageSize: Double = Double(imgData.count) / 1000.0
        if imageSize > 5000 {
            let precentage = 5000 / imageSize
            return image.resize(withPercentage: CGFloat(precentage)) ?? image
        } else {
            return image
        }
    }
    

    // MARK: - Meme Functions
    
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
    
    func save(memedImage: UIImage) {
        
        let meme = Meme(
            topText: topTextField.text!,
            topTextAttributes: topTextField.defaultTextAttributes,
            bottemText: bottomTextField.text!,
            bottomTextAttributes: bottomTextField.defaultTextAttributes,
            orginalImage: orginalImage!,
            croppedImage: imageView.image!,
            memedImage: memedImage,
            croppedImageXFactor: croppedImageXFactor ?? 0,
            croppedImageYFactor: croppedImageYFactor ?? 0,
            croppedImageWidthFactor: croppedImageWidthFactor ?? 1,
            croppedImageHeightFactor: croppedImageHeightFactor ?? 1
        )
        
        if isNewMeme {
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        } else {
            (UIApplication.shared.delegate as! AppDelegate).memes[memeToEditIndex!.row] = meme
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
    }
    
    
    // MARK: - Share Functions
    
    @IBAction func shareMeme() {
        
        if let activeTextField = activeTextField {
            activeTextField.resignFirstResponder()
        }
        
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type,completed,items,error) in
            if ( completed ) {
                self.save(memedImage: memedImage)
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismessMemeEditorView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Crop Functions
    
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
    
    
    // MARK: - Font View Functions
    
    func setUpFontView(activeTextField: UITextField) {
        if let fontView = fontView {
            fontView.removeFromSuperview()
        }
        fontView = FontView()
        fontView.activeTextField = activeTextField
        view.addSubview(fontView)
        fontView.setUp()
        fontView.setUpLayout()
        fontView.isHidden = false
        fontView.checkFont()
    }
    
    // MARK: - Keyboard Behavour
    
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


// MARK: - UIImage resize method

extension UIImage {
    func resize(withPercentage percentage: CGFloat) -> UIImage? {
           let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
           return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
               _ in draw(in: CGRect(origin: .zero, size: canvas))
           }
       }
}

