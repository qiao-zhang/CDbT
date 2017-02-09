//
// Created by Qiao Zhang on 2/9/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import UIKit

protocol NoteWithAttachmentsView: class {
  func update(title: String)
  func update(body: String)
  func update(image: UIImage)
}

class NoteWithAttachmentsPresenter: NoteWithAttachmentsDetailViewEventHandler {
  
  private let note: Note
  private unowned let view: NoteWithAttachmentsView
  
  init(note: Note, view: NoteWithAttachmentsView) {
    self.note = note
    self.view = view
  }
  
  func viewLoaded() {
    view.update(title: note.title)
    view.update(body: note.body)
    if let image = note.image { view.update(image: image) }
  }
}
