import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        fetchUserData()
        fetchProductsFromFirestore()
    }
    
    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let name = document.data()?["name"] as? String ?? "مستخدم"
                DispatchQueue.main.async {
                    self?.usernameLabel.text = "\(name)!"
                }
            }
        }
    }
    
    private func fetchProductsFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("products").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            self?.products.removeAll()
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let imageUrl = data["imageUrl"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                
                let product = Product(id: id, name: name, price: price, imageUrl: imageUrl, description: description)
                self?.products.append(product)
            }
            
            DispatchQueue.main.async {
                self?.productsCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - دالة إضافة المنتج للسلة من الرئيسية
    private func addProductToCart(product: Product) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let cartData: [String: Any] = [
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "description": product.description
        ]
        
        db.collection("users").document(uid).collection("cart").document(product.id).setData(cartData) { [weak self] error in
            if let error = error {
                print("حدث خطأ أثناء الإضافة للسلة: \(error.localizedDescription)")
                return
            }
            
            // إظهار تنبيه نجاح للمستخدم
            let alert = UIAlertController(title: "نجاح", message: "تمت إضافة \(product.name) إلى السلة", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسناً", style: .default, handler: nil))
            self?.present(alert, animated: true)
        }
    }
    
    // MARK: - إعدادات Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell
        
        let product = products[indexPath.row]
        cell.configure(with: product)
        
        // ربط ضغطة الزر داخل الخلية بالدالة الموجودة في الشاشة الرئيسية
        cell.addToCartAction = { [weak self] in
            self?.addProductToCart(product: product)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 64
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.row]
        
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

// MARK: - كلاس الخلية
class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    // 1. أضفنا رابط لزر الزائد (+)
    @IBOutlet weak var addToCartButton: UIButton!
    
    // 2. مسار (Closure) لتنفيذ أمر الإضافة
    var addToCartAction: (() -> Void)?
    
    func configure(with product: Product) {
        productNameLabel.text = product.name
        productPriceLabel.text = "\(product.price) JD"
        productImageView.backgroundColor = .systemGray5
        productImageView.loadImage(from: product.imageUrl)
    }
    
    // 3. دالة تتنفذ عند الضغط على الزر داخل المربع
    @IBAction func addToCartTapped(_ sender: UIButton) {
        addToCartAction?()
    }
}

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                    self?.backgroundColor = .clear
                }
            }
        }
    }
}
