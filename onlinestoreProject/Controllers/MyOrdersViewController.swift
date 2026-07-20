//
//  MyOrdersViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 09/07/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyOrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orders: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchOrders()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
        let order = orders[indexPath.row]
        cell.configure(with: order)
        return cell
    }
    
    private func fetchOrders() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("orders").getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            
            self?.orders.removeAll()
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let date = data["date"] as? String ?? "تاريخ غير متوفر"
                let total = data["total"] as? Double ?? 0.0
                
                let order = Order(id: id, date: date, total: total)
                self?.orders.append(order)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
    
    @IBOutlet weak var cardd: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardd.layer.cornerRadius = 8
        cardd.layer.frame = cardd.layer.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    func configure(with order: Order) {
        orderNumberLabel.text = "طلب #\(order.id.prefix(5))"
        orderDateLabel.text = order.date
        orderTotalLabel.text = " \(order.total) JD"
    }
}
