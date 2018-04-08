//
//  ViewController.swift
//  To Do List
//
//  Created by Ian Yang on 3/16/18.
//  Copyright © 2018 Ian Yang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, AddItemViewControllerDelegate {
    let headers = ["To Beast", "Beasted"]
    var tableData:[String:[ListItem]] = ["To Beast":[],
                                       "Beasted":[]]
    
    
    

    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let manageObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var header = headers[indexPath.section]
        if header == "To Beast" {
            tableData["Beasted"]!.append(tableData[header]![indexPath.row])
            tableData[header]![indexPath.row].completed = false
            tableData[header]?.remove(at: indexPath.row)
            
        } else {
            tableData["To Beast"]!.append(tableData[header]![indexPath.row])
            tableData[header]![indexPath.row].completed = true
            tableData[header]?.remove(at: indexPath.row)
        }
        appDelegate.saveContext()
        fetchAllItems()
        tableView.reloadData()
//        items[indexPath.row].completed = !items[indexPath.row].completed
//        appDelegate.saveContext()
//        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        let item = items[indexPath.row]
//        manageObjectContext.delete(item)
//        do {
//            try manageObjectContext.save()
//        } catch {
//            print("\(error)")
//        }
//        items.remove(at: indexPath.row)
//        tableView.reloadData()
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            var header = self.headers[indexPath.section]
            let item = self.tableData[header]![indexPath.row]
            self.manageObjectContext.delete(item)
            do {
                try self.manageObjectContext.save()
            } catch {
                print("\(error)")
            }
            self.tableData[header]?.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "editItemSegue", sender: indexPath )
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]

    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let header = headers[section]
        return tableData[header]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellTableViewCell
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        
        let header = headers[indexPath.section]
        
        
        cell.titleLabel.text = tableData[header]![indexPath.row].title
        cell.dateLabel.text = dateFormatter.string(from: tableData[header]![indexPath.row].date!)
        cell.descLabel.text = tableData[header]![indexPath.row].desc
        

        return cell
    }
    

    
    func fetchAllItems(){
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        do {
            tableData["Beasted"] = []
            tableData["To Beast"] = []
            let result = try manageObjectContext.fetch(request)
            var items = result as! [ListItem]
            for item in items {
                if item.completed {
                    tableData["To Beast"]!.append(item)
                }
                else {
                    tableData["Beasted"]!.append(item)
                }
            }
        } catch {
            print("\(error)")
        }
        
    }
    
    func addListItem(title: String, desc: String, date: Date, at indexPath: IndexPath?) {
        
        if let ip = indexPath {
            var header = headers[(indexPath?.section)!]
            let item = tableData[header]![ip.row]
            item.title = title
            item.desc = desc
            item.date = date
            
        } else {
            
        let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: manageObjectContext) as! ListItem
        var header = headers[0]
        item.title = title
        item.desc = desc
        item.date = date
        item.completed = false
        
        tableData[header]!.append(item)
        
        appDelegate.saveContext()
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    
    }
    
    func cancelButtonPressed(by controller: AddItemViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addItemViewController = segue.destination as! AddItemViewController
        addItemViewController.delegate = self
        
        
        if let indexPath = sender as? IndexPath {
            var header = headers[indexPath.section]
            let item = tableData[header]![indexPath.row]
            addItemViewController.desc = item.desc
            addItemViewController.t = item.title
            addItemViewController.date = item.date
            addItemViewController.indexPath = indexPath
            addItemViewController.buttonText = "Edit Item"
    
            
            }
    }
    
    
    
    
}

