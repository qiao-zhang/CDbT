//
//  NoteWithAttachmentsDetailViewController.swift
//  CDbT
//
//  Created by Qiao Zhang on 2/9/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit

protocol NoteWithAttachmentsDetailViewEventHandler {
  func viewLoaded()
}

class NoteWithAttachmentsDetailViewController:
    UIViewController, NoteWithAttachmentsView {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var bodyTextView: UITextView!
  @IBOutlet weak var imageView: UIImageView!
  
  var eventHandler: NoteWithAttachmentsDetailViewEventHandler!

  override func viewDidLoad() {
    super.viewDidLoad()
    eventHandler.viewLoaded()
  }

  func update(title: String) {
    titleLabel.text = title
  }
  
  func update(body: String) {
    bodyTextView.text = body
  }
  
  func update(image: UIImage) {
    imageView.image = image
  }
}
