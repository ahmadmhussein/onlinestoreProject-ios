//
//  CartViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 09/07/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var cartItems: [Product] = []
    var cartTotal: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        checkoutButton.layer.cornerRadius = 8
        fetchCartItems()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
        let product = cartItems[indexPath.row]
        cell.configure(with: product)
        
        cell.deleteAction = { [weak self] in
            self?.deleteItem(at: indexPath)
        }
        return cell
    }
    
    private func fetchCartItems() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("cart").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            
            self?.cartItems.removeAll()
            var total: Double = 0.0
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let imageUrl = data["imageUrl"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                
                let product = Product(id: id, name: name, price: price, imageUrl: imageUrl, description: description)
                self?.cartItems.append(product)
                total += price
            }
            
            DispatchQueue.main.async {
                self?.cartTotal = total
                self?.totalPriceLabel.text = "\(total) JD"
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let productId = cartItems[indexPath.row].id
        Firestore.firestore().collection("users").document(uid).collection("cart").document(productId).delete()
    }
    
    @IBAction func checkoutTapped(_ sender: UIButton) {
        guard !cartItems.isEmpty else {
            showAlert(title: "تنبيه", message: "السلة فارغة، أضف منتجات أولاً.")
            return
        }
        
        if let checkoutVC = storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController {
            checkoutVC.orderTotal = self.cartTotal
            checkoutVC.orderedItems = self.cartItems
            checkoutVC.modalPresentationStyle = .fullScreen
            present(checkoutVC, animated: true, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "حسناً", style: .default))
        present(alert, animated: true)
    }
}
class CartItemCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteAction: (() -> Void)?
    
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
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteAction?()
    }
}
