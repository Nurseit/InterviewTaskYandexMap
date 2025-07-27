import UIKit
import SnapKit

final class BookmarkViewCell: UICollectionViewCell {
    static let reuseId = "AddressCell"

    private var placeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        label.text = "Место"
        return label
    }()
    private var adressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(named: "text_grey_light")
        return label
    }()
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ic_location_heart")
        return imageView
    }()
    
    var longPressed: (() -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commoInit()
        addSubview()
        addConstraints()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commoInit() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.allowableMovement = 10
        longPressRecognizer.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    private func addSubview() {
        contentView.addSubview(placeLabel)
        contentView.addSubview(adressLabel)
        contentView.addSubview(iconImageView)
    }
    
    private func addConstraints() {
        placeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(adressLabel.snp.trailing)
        }
        adressLabel.snp.makeConstraints { make in
            make.top.equalTo(placeLabel.snp.bottom).offset(7)
            make.bottom.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
        }
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(adressLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
        guard case .began = gesture.state else { return }
        longPressed?()
    }
        
    func fill(with model: Address) {
        adressLabel.text = model.name
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetWidth = layoutAttributes.size.width - 32 // 16 * 2 inset
        adressLabel.preferredMaxLayoutWidth = targetWidth
        placeLabel.preferredMaxLayoutWidth = targetWidth
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let newAttributes = layoutAttributes
        
        newAttributes.frame.size = CGSize(width: layoutAttributes.size.width, height: size.height)
        return newAttributes
    }
}

