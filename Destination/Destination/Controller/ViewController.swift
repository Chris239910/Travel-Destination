//
//  ViewController.swift
//  Destination
//
//  Created by english on 2020-11-30.
//  Copyright © 2020 Chris. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var nameArray = [String]()
    var idArray = [UUID]()
    var images = [Data]()
    var countryArray = [String]()
    var selectedDestinationName = ""
    var selectedDestinationId : UUID?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = nameArray[indexPath.row]
        cell.detailTextLabel?.text = countryArray[indexPath.row]
        cell.imageView?.image = UIImage(data: images[indexPath.row])
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClick))
        
        getData()
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //getData()
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newDestination"), object: nil)
    }
    @objc func getData(){
        //remove everything
        nameArray.removeAll()
        idArray.removeAll()
        countryArray.removeAll()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destination")
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let country = result.value(forKey: "country") as? String{
                        countryArray.append(country)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    if let image = result.value(forKey: "image") as? Data{
                        images.append(image);
                    }
                    tableView.reloadData()
                }
            }
        }catch{
            print("Error")
        }
        
    }
    
    @objc func addButtonClick(){
        selectedDestinationName = ""
        performSegue(withIdentifier: "SC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDestinationId = idArray[indexPath.row]
        selectedDestinationName = nameArray[indexPath.row]
        performSegue(withIdentifier: "SC", sender: "nil")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SC"{
            let des = segue.destination as! SecondViewController
            des.choosenDestinationId = selectedDestinationId
            des.choosenDestinationName = selectedDestinationName
    
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //delete from painting where Id = ??
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destination")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            tableView.reloadData()
                            do{
                                try context.save()
                            }catch{
                                print("Error")
                            }
                                break
                        }
                    }
                        
                }
            }
        }catch{
            print("Error")
        }
            
        }
    }
    
    


}

