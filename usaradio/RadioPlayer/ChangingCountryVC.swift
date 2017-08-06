//
//  ChangingCountryVC.swift
//  RadioPlayer
//
//  Created by Apple Family on 7/13/17.
//  Copyright © 2017 Apple Family. All rights reserved.
//

import UIKit
import CoreData

class ChangingCountryVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var _countryPicker: UIPickerView!
    
    var delController: NSFetchedResultsController<Channel>!
    
    let sortedCountriesList = CountriesList.sorted(by: { $0 < $1 })

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _countryPicker.dataSource = self
        _countryPicker.delegate = self
        
        self.doneButton.layer.borderWidth = 2.0
        self.doneButton.layer.borderColor = UIColor.blue.cgColor
        self.doneButton.layer.cornerRadius = 5
        self.cancelButton.layer.borderWidth = 2.0
        self.cancelButton.layer.borderColor = UIColor.red.cgColor
        self.cancelButton.layer.cornerRadius = 5
        
        UserDefaults.standard.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.doneButton.isEnabled = false
        self.cancelButton.isEnabled = false
        self.doneButton.setTitle("Loading...", for: .normal)
        let pickedCountry = sortedCountriesList[_countryPicker.selectedRow(inComponent: 0)]
        
        if UserDefaults.standard.string(forKey: KEY_PICKED_COUNTRY) != pickedCountry {
            UserDefaults.standard.set(pickedCountry, forKey: KEY_PICKED_COUNTRY)
            //Delete all current data
            self.deleteAllChannels()
            //Load new data
            UtilClass.downloadJsonData(url : UtilClass.countryURL(name: pickedCountry)){
                UtilClass.saveChannelToCoreData()
                self.navigationController?.popViewController(animated: true)
                self.performSegue(withIdentifier: "changeCountry", sender: nil)
            }
        } else {
            
            
            self.navigationController?.popViewController(animated: true)
            
            self.performSegue(withIdentifier: "changeCountry", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.doneButton.isEnabled = true
        self.cancelButton.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedCountriesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortedCountriesList[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func deleteAllChannels()
    {        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.reset()
        let fetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in Channel error : \(error) \(error.userInfo)")
        }
        
        appDelegate.saveContext()
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
