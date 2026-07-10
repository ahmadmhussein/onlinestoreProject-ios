//
//  ProductDetailsViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 08/07/2026.
//

import UIKit

class ProductDetailsViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
        @IBOutlet weak var productNameLabel: UILabel!
        @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateData()
       
    }
    private func setupUI() {
            addToCartButton.layer.cornerRadius = 12
            
            productImageView.layer.cornerRadius = 24
            productImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            productImageView.clipsToBounds = true
        }

    private func populateData() {
            guard let product = product else { return }
            
            productNameLabel.text = product.name
            productPriceLabel.text = "\(product.price) JD"
            productDescriptionTextView.text = product.description
            
            productImageView.loadImage(from: product.imageUrl)
        }
    @IBAction func addToCartTapped(_ sender: UIButton) {
            // سيتم برمجة سلة المشتريات هنا لاحقاً
            print("تمت إضافة \(product?.name ?? "") إلى السلة بنجاح!")
        }
}
