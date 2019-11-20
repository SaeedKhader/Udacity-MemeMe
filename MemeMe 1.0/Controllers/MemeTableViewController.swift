//
//  MemeTableViewController.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 09/11/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var memes: [Meme]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    var isEditingOn = false
    
    var editButton: UIBarButtonItem!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refresh") , object: nil)

        editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(toggleEditMode))
        
        self.navigationItem.leftBarButtonItem = editButton
        
    }

    @objc func refreshTable() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeTableCell", for: indexPath) as! MemeTableViewCell
        let meme = memes[indexPath.row]
        cell.memedImageView.image = meme.memedImage
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottemText
        cell.editView.isHidden = !isEditingOn
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingOn {
            presentMemeEditorViewController(meme: self.memes[indexPath.row], indexPath: indexPath)
        } else {
            let memePreviewController = self.storyboard!.instantiateViewController(withIdentifier:  "memePreviewViewController") as! MemePreviewViewController
            memePreviewController.meme = memes[indexPath.row]
            memePreviewController.indexPath = indexPath
            memePreviewController.memeTableViewController = self
            memePreviewController.modalPresentationStyle = .fullScreen
            self.present(memePreviewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              appDelegate.memes.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .fade)
          }
      }
    
 
    @objc func toggleEditMode() {
        isEditingOn.toggle()
        editButton.title = isEditingOn ? "Done" : "Edit"
        
        for cell in tableView.visibleCells {
            let cell = cell as! MemeTableViewCell
            cell.editView.isHidden = !isEditingOn
        }
    }
    
    func presentMemeEditorViewController(meme: Meme, indexPath: IndexPath){
        let memeEditorController = self.storyboard!.instantiateViewController(withIdentifier:  "memeEditorViewController") as! MemeEditorViewController
        memeEditorController.isNewMeme = false
        memeEditorController.memeToEditIndex = indexPath
        memeEditorController.memeToEdit = meme
        memeEditorController.modalPresentationStyle = .fullScreen
        self.present(memeEditorController, animated: true, completion: nil)
    }
    
}
