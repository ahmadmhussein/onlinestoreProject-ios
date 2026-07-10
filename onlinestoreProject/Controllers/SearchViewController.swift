//
//  SearchViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 07/07/2026.
//
import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var allProducts: [Product] = []
    var filteredProducts: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        
        fetchProductsFromFirestore()
    }
    
    private func fetchProductsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("products").getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            
            self?.allProducts.removeAll()
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let imageUrl = data["imageUrl"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                
                let product = Product(id: id, name: name, price: price, imageUrl: imageUrl, description: description)
                self?.allProducts.append(product)
            }
            
            self?.filteredProducts = self?.allProducts ?? []
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredProducts = allProducts
        } else {
            filteredProducts = allProducts.filter { product in
                return product.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchProductCell", for: indexPath) as! SearchProductCell
        
        let product = filteredProducts[indexPath.row]
        cell.configure(with: product)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProduct = filteredProducts[indexPath.row]
        
        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            
            detailsVC.product = selectedProduct
            
            detailsVC.modalPresentationStyle = .pageSheet
            if let sheet = detailsVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(detailsVC, animated: true)
        }
    }
}

class SearchProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        productImageView.backgroundColor = .systemGray6
    }
    
    func configure(with product: Product) {
        productNameLabel.text = product.name
        productPriceLabel.text = "\(product.price) JD"
        productImageView.loadImage(from: product.imageUrl)
    }
}
