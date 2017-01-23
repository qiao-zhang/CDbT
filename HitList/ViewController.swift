//
//  ViewController.swift
//  HitList
//
//  Created by Qiao Zhang on 1/23/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  var people: [NSManagedObject] = []
  
  // MARK: View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
    
    do {
      people = try managedContext.fetch(fetchRequest)
    } catch {
      let userInfo = (error as NSError).userInfo
      print("Could not fetch. \(error), \(userInfo)")
    }
  }


  private func setupUI() {
    navigationItem.title = "The List"
    
    let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(addButtonTapped))
    navigationItem.rightBarButtonItem = addBarButtonItem
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.dataSource = self
  }
  
  @objc private func addButtonTapped() {
    let alertController = UIAlertController(title: "New Name",
                                            message: "Add a new name",
                                            preferredStyle: .alert)
    let saveAction = UIAlertAction(title: "Save", style: .default) {
      [unowned self] action in
      guard let textField = alertController.textFields?.first,
          let name = textField.text else { return }
      
      self.save(name: name)
      self.tableView.reloadData()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
    alertController.addTextField()
    [saveAction, cancelAction].forEach { alertController.addAction($0) }
    
    present(alertController, animated: true)
  }
  
  private func save(name: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "Person",
                                            in: managedContext)!
    let person = NSManagedObject(entity: entity, insertInto: managedContext)
    person.setValue(name, forKey: "name")
    
    do {
      try managedContext.save()
      people.append(person)
    } catch {
      let userInfo = (error as NSError).userInfo
      print("Could not save. \(error), \(userInfo)")
    }
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
    let person = people[indexPath.row]
    cell.textLabel?.text = person.value(forKeyPath: "name") as? String
    return cell
  }

}

