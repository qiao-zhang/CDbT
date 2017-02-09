/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CoreData
import UIKit

class Note: NSManagedObject {
  @NSManaged var title: String
  @NSManaged var body: String
  @NSManaged var dateCreated: Date!
  @NSManaged var displayIndex: NSNumber!
  @NSManaged var attachments: Set<Attachment>?
  
  var image: UIImage? {
    return latestAttachment?.image
  }
  
  private var latestAttachment: Attachment? {
    guard let attach = attachments,
          let startingAttachment = attach.first else { return nil }
    return Array(attach).reduce(startingAttachment) {
      $0.dateCreated.compare($1.dateCreated) == .orderedAscending ? $0 : $1
    }
  }
  
  override func awakeFromInsert() {
    super.awakeFromInsert()
    dateCreated = Date()
  }
}
