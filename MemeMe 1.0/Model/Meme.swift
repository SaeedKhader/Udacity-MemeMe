//
//  Meme.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 02/11/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String
    var topTextAttributes: [NSAttributedString.Key : Any]
    var bottemText: String
    var bottomTextAttributes: [NSAttributedString.Key : Any]
    var orginalImage: UIImage
    var croppedImage: UIImage
    var memedImage: UIImage
    
    var croppedImageXFactor: CGFloat
    var croppedImageYFactor: CGFloat
    var croppedImageWidthFactor: CGFloat
    var croppedImageHeightFactor: CGFloat
}
