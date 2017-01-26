/**
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

class ViewController: UIViewController {

  // MARK: - Properties
  private let filterViewControllerSegueIdentifier = "toFilterViewController"
  fileprivate let venueCellIdentifier = "VenueCell"

  var coreDataStack: CoreDataStack!
  var fetchRequest: NSFetchRequest<Venue>!
  var venues: [Venue]!

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
    batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite): true]
    batchUpdate.affectedStores = coreDataStack.managedContext
        .persistentStoreCoordinator?.persistentStores
    batchUpdate.resultType = .updatedObjectsCountResultType
    
    do {
      let batchResult = try coreDataStack.managedContext.execute(
          batchUpdate) as! NSBatchUpdateResult
      print("\(batchResult.result!) records updated")
    } catch {
      let nsError = error as NSError
      print("Could not update \(nsError), \(nsError.userInfo)")
    }
    
    fetchRequest = Venue.fetchRequest()
    fetchAndReload()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == filterViewControllerSegueIdentifier,
          let navController = segue.destination as? UINavigationController,
          let filterVC = navController
              .topViewController as? FilterViewController else {
      return
    }
    
    filterVC.coreDataStack = coreDataStack
    filterVC.delegate = self
  }
  
  // MARK: Other methods
  func fetchAndReload() {
    do {
      venues = try coreDataStack.managedContext.fetch(fetchRequest)
      tableView.reloadData()
    } catch {
      let nsError = error as NSError
      print("Could not fetch \(nsError), \(nsError.userInfo)")
    }
  }
  
  func deleteAllVenues() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Venue.fetchRequest()
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    batchDelete.resultType = .resultTypeCount
    do {
      let result = try coreDataStack.managedContext.execute(
          batchDelete) as! NSBatchDeleteResult
      print("\(result.result!) records deleted")
    } catch {
      let nsError = error as NSError
      print("Could not delete \(nsError), \(nsError.userInfo)")
    }
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
  }

  @IBAction func reset() {
    deleteAllVenues()
    (UIApplication.shared.delegate as! AppDelegate).importJSONSeedDataIfNeeded()
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return venues.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: venueCellIdentifier,
        for: indexPath)
    let venue = venues[indexPath.row]
    
    cell.textLabel?.text = venue.name
    cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
    return cell
  }
}

extension ViewController: FilterViewControllerDelegate {
  func filterViewController(filter: FilterViewController,
                            didSelectPredicate predicate: NSPredicate?,
                            sortDescriptor: NSSortDescriptor?) {
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = nil
    if let sr = sortDescriptor {
      fetchRequest.sortDescriptors = [sr]
    }
    fetchAndReload()
  }
}
