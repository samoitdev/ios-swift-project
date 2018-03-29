//
//  WineViewController.swift
//  ToDoing
//
//  Created by Samuel Benoit on 2018-03-24.
//  Copyright © 2018 comp3097. All rights reserved.
//

import UIKit
import CoreData

class WineViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    var wine: Wine?
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(with: )),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        
        nameTextField.becomeFirstResponder()
        
        if let wine = wine {
            nameTextField.text = wine.name
            brandTextField.text = wine.brand
            priceTextField.text = wine.price
            segmentedControl.selectedSegmentIndex = Int(wine.type)
        }
    
    }
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottomConstriant.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        
        guard let brand = brandTextField.text, !brand.isEmpty else {
            return
        }
        
        guard let price = priceTextField.text, !price.isEmpty else {
            return
        }
        
        if let wine = self.wine {
            wine.name = name
            wine.brand = brand
            wine.price = price
            wine.updated_on = Date()
            wine.type = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let wine = Wine(context: managedContext)
            wine.name = name
            wine.brand = brand
            wine.price = price
            wine.type = Int16(segmentedControl.selectedSegmentIndex)
            wine.created_on = Date()
        }
        
        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print(">>> Error: \(error)")
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        nameTextField.resignFirstResponder()
    }

}
