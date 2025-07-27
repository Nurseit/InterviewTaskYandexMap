import UIKit

final class MapAdressBottomSheetView: UIView {
    private var adressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(named: "text_grey_light")
        return label
    }()
    
    private var addFavouritebutton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить в избранное", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "button_green")
        return button
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_close"), for: .normal)
        button.tintColor = UIColor(named: "icon_close_grey")
        return button
    }()
    
    var onTapAddFavourite: (() -> Void)?
    var onTapClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addSubViews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addFavouritebutton.addTarget(self, action: #selector(addFavourite(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeBottomSheet(_:)), for: .touchUpInside)
        addFavouritebutton.layer.cornerRadius = 20
    }
    
    private func addSubViews() {
        addSubview(adressLabel)
        addSubview(addFavouritebutton)
        addSubview(closeButton)
    }
    
    private func addConstraints() {
        adressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(16)
        }
        addFavouritebutton.snp.makeConstraints { make in
            make.top.equalTo(adressLabel.snp.bottom).offset(20)
            make.leading.equalTo(adressLabel)
            make.bottom.equalToSuperview().inset(40)
            make.width.equalTo(220)
            make.height.equalTo(42)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalTo(adressLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(17)
            make.size.equalTo(21)
        }
        closeButton.imageView?.snp.makeConstraints { make in
            make.size.equalTo(21)
        }
    }
    
    @objc private func addFavourite(_ sender: UIButton) {
        onTapAddFavourite?()
    }
    
    @objc private func closeBottomSheet(_ sender: UIButton) {
        onTapClose?()
    }
    
    func setTitle(text: String) {
        adressLabel.text = text
    }
}
