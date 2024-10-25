//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray : [TodoData] = []
    var selectedCategory : CategoryData? {
        didSet {
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        navigationItem.title = selectedCategory?.name
    }
    
    
    //MARK: TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.text
        
        cell.accessoryType = item.checked ? .checkmark : .none
        
        
        return cell
    }
    
    
    //MARK: TableView Delegate
    //-> check/uncheck datas , Deselecting rows
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //If user selects any row , this line of code will change its mark
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        self.saveItems()
        
    }
    
    //MARK: Add New Items
    //-> Receiving data/defining our context/saving our new data to SQLite using CoreData
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // Checking if user typed something
            if textField.text != "" {
                let newItem = TodoData(context: self.context)
                newItem.text = textField.text!
                newItem.checked = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                // Asking CoreData to save new datas
                self.saveItems()
                
                
            } else {
                // If not typed anything , alert them to type
                let alert = UIAlertController(title: "Error", message: "Please enter an item", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Data Manipulation
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error Saving Data: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<TodoData> = TodoData.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error Reading Data: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    
}

//MARK: Searchbar Delegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dispatchQUEUE(with: searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            
            dispatchQUEUE(with: searchBar)
            
        } else {
            let request: NSFetchRequest<TodoData> = TodoData.fetchRequest()
            
            let predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
        }
    }
    
    func dispatchQUEUE(with searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
}
