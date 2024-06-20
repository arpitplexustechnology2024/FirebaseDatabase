//
//  ProductListViewController.swift
//  FirebaseDatabase
//
//  Created by Arpit iOS Dev. on 20/06/24.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var products: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
            self.tableView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.fetchProducts()
        }
    }
    
    func fetchProducts() {
        FirestoreManager.shared.fetchAllProducts { result in
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self.products = products
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failed to fetch products: \(error)")
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListTableViewCell", for: indexPath) as? ProductListTableViewCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        cell.nameLabel.text = product["name"] as? String
        cell.descriptionLabel.text = product["description"] as? String
        cell.weightLabel.text = product["weight"] as? String
        
        if let imageURL = product["imageURL"] as? String {
            cell.productImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.productImageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 159
    }
}
