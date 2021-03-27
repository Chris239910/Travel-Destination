//
//  SecondViewController.swift
//  Destination
//
//  Created by english on 2020-11-30.
//  Copyright © 2020 Chris. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var choosenDestinationName = ""
    var choosenDestinationId :UUID?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var budget: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func savePressed(_ sender: UIButton) {
        //check the textfileds are not empty
        //because name field use keyboard protocol -> just test 3 others field
        if country.text! != ""{
                if year.text! != ""{
                    if budget.text! != ""{
                        //when all the textfield are not empty
                        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appdelegate.persistentContainer.viewContext
                        
                        let newDestination = NSEntityDescription.insertNewObject(forEntityName: "Destination", into: context)
                        
                        newDestination.setValue(name.text!, forKey: "name")
                        newDestination.setValue(country.text!, forKey: "country")
                        if let year = Int(year.text!){
                            newDestination.setValue(year, forKey: "year")
                        }
                        if let budget = Int(budget.text!){
                            newDestination.setValue(budget, forKey: "budget")
                        }
                        let data = imageView.image?.jpegData(compressionQuality: 0.5)
                        newDestination.setValue(data, forKey: "image")
                        newDestination.setValue(UUID(), forKey: "id")
                        
                        do{
                            try context.save()
                            print("Success")
                        }catch{
                            print("Error")
                        }
                        
                        //sending notifications
                        NotificationCenter.default.post(name: NSNotification.Name("newDestination"), object: nil)
                        //pop the top view controller
                        navigationController?.popViewController(animated: true)
                    }else{
                        budget.placeholder = "You must enter budget"
                        }
                }
                else{
                    year.placeholder = "You must enter Year"
                }
            }else{
                country.placeholder = "You must enter Country"
                }
 
    }
    //validation for name field - name.text
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if name.text! != ""{
            return true
        }else{
            name.placeholder = "Enter name"
            return true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the datas when click onto tableViewCell in Viewcontroller
        getDataById()
        
        //define textfield for validation
        name.delegate = self
        country.delegate = self
        year.delegate = self
        budget.delegate = self
        

        //image tag recognizer
        imageView.isUserInteractionEnabled = true
        //create recognizer
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //value of info is dictionary
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func getDataById(){
    if choosenDestinationName != "" {
        saveBtn.isHidden = true
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destination")
        let idString = choosenDestinationId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let placeName = result.value(forKey: "name") as? String{
                        name.text = placeName
                    }
                    if let placeCountry = result.value(forKey: "country") as? String{
                        country.text = placeCountry
                    }
                    if let yearPlan = result.value(forKey: "year") as? Int{
                        year.text = String(yearPlan)
                    }
                    if let budgetPlan = result.value(forKey: "budget") as? Int{
                        budget.text = String(budgetPlan)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        imageView.image = UIImage(data: imageData)
                    }
                    
                }
            }
        }catch{
            print("Error")
        }
    
    }else{
        saveBtn.isHidden = false
    }

    }
}
