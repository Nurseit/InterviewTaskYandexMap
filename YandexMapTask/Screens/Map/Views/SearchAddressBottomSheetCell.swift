import UIKit

final class SearchAddressBottomSheetCell: UITableViewCell {
    static let reuseId = "SearchAddressCell"
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        iconImageView.image = UIImage(named: "ic_location")?.withTintColor(UIColor(named: "icon_grey_bottom_sheet_cell") ?? .gray)
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = .black
    }
    
    private func addSubviews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
    }
    
    private func addConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(17)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(24)
            make.height.equalTo(29)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(17)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(17)
        }
    }
    
    func fill(title: String) {
        titleLabel.text = title
    }
    
    func getAddress() -> String {
        return titleLabel.text ?? ""
    }
}
