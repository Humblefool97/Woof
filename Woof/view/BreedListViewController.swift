//
//  BreedListViewController.swift
//  Woof
//
//  Created by Rajeev Ranganathan on 27/12/18.
//  Copyright © 2018 Rajeev Ranganathan. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BreedListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var breeds:[Breeds] = []
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var filteredBreeds: [Breeds] = []
    var searchController = UISearchController(searchResultsController: nil)
    var fetchedResultsController:NSFetchedResultsController<CoreDataBreeds>!


    fileprivate func configureSearchBar() {
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUpFetchResultsController()
        fetchBreeds()
        configureSearchBar()
    }

    func setUpFetchResultsController(){
        let breedsFetchRequest = NSFetchRequest<CoreDataBreeds>(entityName: "CoreDataBreeds")
        breedsFetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: breedsFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
            let count = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<count{
                let breed = fetchedResultsController.object(at: IndexPath(row: index, section: 0))
                let breedObj = Breeds()
                breedObj.id = breed.id
                breedObj.name = breed.name
                breeds.append(breedObj)
            }
        } catch  {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func fetchDogById(id:Int){
        BreedsController.Shared.getDogByBreed(breedId:id){
            (isSuccess,response,errorMessage) in
            self.activityIndicator.stopAnimating()
            if(isSuccess){
                if let dog = response {
                    let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailvc") as! DetailViewController
                    destinationViewController.dog = dog
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
            }else{
                //Handle failure case
            }
        }
        
    }
    fileprivate func fetchBreeds(){
        if(breeds.isEmpty){
            BreedsController.Shared.getBreeds{
                (isSuccess,response,errorMessage) in
                if(isSuccess){
                    if let response = response{
                        self.breeds = response
                        DispatchQueue.global(qos: .userInitiated).async {
                            for breed in self.breeds {
                                let _ = CoreDataBreeds(id: breed.id, name: breed.name, context: DataController.shared.viewContext)
                                DataController.shared.saveContext()
                            }
                        }
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }else{
                    //Handle failure case here
                }
            }
        }else{
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
}
