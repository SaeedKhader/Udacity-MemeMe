//
//  MemePreviewViewController.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 18/11/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class MemePreviewViewController: UIViewController {

    @IBOutlet weak var memePreviewImageView: UIImageView!
    
    var meme: Meme!
    var indexPath: IndexPath!
    var memeTableViewController: MemeTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memePreviewImageView.image = meme.memedImage
    }
        
    @IBAction func edit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        memeTableViewController.presentMemeEditorViewController(meme: meme, indexPath: indexPath)
    }
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
