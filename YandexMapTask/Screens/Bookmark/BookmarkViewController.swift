import UIKit

final class BookmarkViewController: UIViewController {
    var presenter: BookmarkPresenterProtocol?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 80)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BookmarkViewCell.self, forCellWithReuseIdentifier: BookmarkViewCell.reuseId)
        return collectionView
    }()
    private var addresses: [Address] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bg_primary")
        navigationItem.title = "Мои адреса"
        addSubviews()
        addConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func addConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func loadData() {
        addresses = presenter?.fetchAddress() ?? []
        collectionView.reloadData()
    }
}

extension BookmarkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookmarkViewCell.reuseId,
            for: indexPath
        ) as? BookmarkViewCell
        else {
            return UICollectionViewCell()
        }
        let address = addresses[indexPath.item]
        
        cell.longPressed = { [weak self] in
            guard let self = self,
                  let uuid = address.id
            else {
                return
            }
            
            self.presenter?.deleteBookmark(at: uuid)
            if let actualIndex = self.addresses.firstIndex(where: { $0.id == address.id }) {
                self.collectionView.performBatchUpdates {
                    self.addresses.remove(at: actualIndex)
                    self.collectionView.deleteItems(at: [IndexPath(item: actualIndex, section: 0)])
                }
            }
        }
        
        cell.fill(with: address)
        return cell
    }
}
