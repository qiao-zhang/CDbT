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

import UIKit
import CoreData

class ViewController: UIViewController, UIBarPositioningDelegate {

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  // MARK: Properties
  var managedContext: NSManagedObjectContext!
  var currentBowtie: Bowtie!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    insertSampleData()
    
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    let firstTitle = segmentedControl.titleForSegment(at: 0)!
    print(firstTitle)
    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle)
    
    do {
      let bowties = try managedContext.fetch(request)
      currentBowtie = bowties.first
      populate(bowtie: bowties.first!)
    } catch {
      let nsError = error as NSError
      print("Could not fetch \(nsError), \(nsError.userInfo)")
    }
  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: AnyObject) {
    guard let control = sender as? UISegmentedControl else { return }
    let selectedValue =
        control.titleForSegment(at: control.selectedSegmentIndex)!
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    request.predicate = NSPredicate(format: "searchKey == %@", selectedValue)
    
    do {
      let results = try managedContext.fetch(request)
      currentBowtie = results.first
      populate(bowtie: currentBowtie)
    } catch {
      let nsError = error as NSError
      print("Could not fetch \(nsError), \(nsError.userInfo)")
    }
  }

  @IBAction func wear(_ sender: AnyObject) {
    currentBowtie.timesWorn += 1
    currentBowtie.lastWorn = NSDate()
    
    do {
      try managedContext.save()
      populate(bowtie: currentBowtie)
    } catch {
      let nsError = error as NSError
      print("Could not fetch \(nsError), \(nsError.userInfo)")
    }
  }
  
  @IBAction func rate(_ sender: AnyObject) {
    let alert = UIAlertController(title: "New Rating",
                                  message: "Rate this bow tie",
                                  preferredStyle: .alert)
    alert.addTextField { $0.keyboardType = .decimalPad }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    let saveAction = UIAlertAction(title: "Save", style: .default) {
      [unowned self] action in
      guard let textField = alert.textFields?.first else { return }
      self.update(rating: textField.text)
    }
    
    [cancelAction, saveAction].forEach { alert.addAction($0) }
    
    present(alert, animated: true)
  }
  
  @IBAction func reset() {
    let fetchRequest = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    do {
      let bowties = try managedContext.fetch(fetchRequest)
      bowties.forEach { managedContext.delete($0) }
      try managedContext.save()
    } catch {
      let nsError = error as NSError
      print("Error when removing all bowties \(nsError), \(nsError.userInfo)")
    }
    insertSampleData()
  }
  
  private func insertSampleData() {
    let fetchRequest = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
    
    let count = try! managedContext.count(for: fetchRequest)
    print(count)
    if count > 0 {
      return
    }
    
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!
    
    print("\(dataArray.count)")
    dataArray.forEach {
      guard let dict = $0 as? [String: AnyObject],
          let name = dict["name"] as? String,
          let searchKey = dict["searchKey"] as? String,
          let rating = dict["rating"] as? Double,
          let colorDict = dict["tintColor"] as? [String: AnyObject],
          let red = colorDict["red"] as? NSNumber, 
          let blue = colorDict["blue"] as? NSNumber,
          let green = colorDict["green"] as? NSNumber,
          let imageName = dict["imageName"] as? String,
          let image = UIImage(named: imageName),
          let photoData = UIImagePNGRepresentation(image),
          let lastWorn = dict["lastWorn"] as? NSDate,
          let timesWorn = dict["timesWorn"] as? NSNumber,
          let isFavorite = dict["isFavorite"] as? Bool else {
        print("failed")
        return
      }
      print("success")
      let tintColor = UIColor(red: CGFloat(red) / 255.0,
                              green: CGFloat(green) / 255.0,
                              blue: CGFloat(blue) / 255.0,
                              alpha: 1)
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie",
                                              in: managedContext)!
      let bowtie = Bowtie(entity: entity, insertInto: managedContext)
      bowtie.name = name
      bowtie.searchKey = searchKey
      bowtie.rating = rating
      bowtie.photoData = NSData(data: photoData)
      bowtie.lastWorn = lastWorn
      bowtie.timesWorn = timesWorn.int32Value
      bowtie.isFavorite = isFavorite
      bowtie.tintColor = tintColor
    }
    
    try! managedContext.save()
  }
  
  private func populate(bowtie: Bowtie) {
    guard let imageData = bowtie.photoData as? Data,
        let tintColor = bowtie.tintColor as? UIColor,
        let lastWorn = bowtie.lastWorn as? Date else {
      print("populate failed")
      return
    }
    
    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
    favoriteLabel.isHidden = !bowtie.isFavorite
    view.tintColor = tintColor
  }
  
  private func update(rating: String?) {
    guard let ratingString = rating, let rating = Double(ratingString) else {
      return
    }
    
    do {
      currentBowtie.rating = rating
      try managedContext.save()
      populate(bowtie: currentBowtie)
    } catch {
      let nsError = error as NSError
      if nsError.domain == NSCocoaErrorDomain && (
          nsError.code == NSValidationNumberTooLargeError ||
              nsError.code == NSValidationNumberTooSmallError) {
        rate(currentBowtie)
      } else {
        print("Could not save \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: Bar Positioning Delegate
  func position(`for` bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}
