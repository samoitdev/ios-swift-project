//
//  ToDoTableViewController.swift
//  ToDoing
//
//  Created by Samuel Benoit on 2018-03-24.
//  Copyright © 2018 comp3097. All rights reserved.
//

import UIKit
import CoreData

class WineTableViewController: UITableViewController {
    
    var resultsController: NSFetchedResultsController<Wine>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<Wine> = Wine.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "created_on", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        resultsController.delegate = self
        
        do {
            try resultsController.performFetch()
        } catch {
            print(">>> Error: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineCell", for: indexPath)

        // Configure the cell...
        let wine = resultsController.object(at: indexPath)
        
        cell.textLabel?.text = wine.name
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            let wine = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(wine)
            
            do {
                try self.resultsController.managedObjectContext.save()
            } catch {
                print(">>> Wine Deletion Failed: \(error)")
            }
            
            completion(true)
        }
        
        //action.image = trash
        
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowWineForm", sender: tableView.cellForRow(at: indexPath))
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? WineViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? WineViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let wine = resultsController.object(at: indexPath)
                vc.wine = wine
            }
        }
    }
}

extension WineTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = newIndexPath, let cell = tableView.cellForRow(at: indexPath) {
                let wine = resultsController.object(at: indexPath)
                cell.textLabel?.text = wine.name
            }
        default:
            break
        }
        
    }
}
