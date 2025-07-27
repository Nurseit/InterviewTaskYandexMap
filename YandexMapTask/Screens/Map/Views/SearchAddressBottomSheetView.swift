import UIKit

protocol SearchAddressBottomSheetViewDelegate: AnyObject {
    func fill(addresses: [String])
}

final class SearchAddressBottomSheetView: UIView {
    private let textFieldView = SearchTextFieldView()
    private let tableView = UITableView()
    private var addresses = [String]()
    var bottomSheetViewHeight: CGFloat = 0
    var onTextHandle: ((String) -> Void)?
    var onSelectedAddressHandle: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        tableView.register(SearchAddressBottomSheetCell.self, forCellReuseIdentifier: SearchAddressBottomSheetCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textFieldView.onTextChange = { [weak self] text in
            self?.onTextHandle?(text)
        }
        textFieldView.onClearButtonTap = { [weak self] in
            self?.addresses.removeAll()
            self?.tableView.reloadData()
        }
    }
    
    private func addSubviews() {
        addSubview(textFieldView)
        addSubview(tableView)
    }
    
    private func addConstraints() {
        textFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(26)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(400)
        }
    }
    
    func hideKeyboard() {
        textFieldView.hideKeyboard()
    }
}

extension SearchAddressBottomSheetView: SearchAddressBottomSheetViewDelegate {
    func fill(addresses: [String]) {
        self.addresses = addresses
        tableView.reloadData()
    }
}

extension SearchAddressBottomSheetView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAddressBottomSheetCell.reuseId, for: indexPath) as? SearchAddressBottomSheetCell else {
            return UITableViewCell(frame: .zero)
        }
        let adress = addresses[indexPath.row]
        
        cell.fill(title: adress)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchAddressBottomSheetCell else { return }
        let address = cell.getAddress()
        
        onSelectedAddressHandle?(address)
    }
}

final private class SearchTextFieldView: UIView {
    private let placeholderView = UIView()
    private let iconImageView = UIImageView()
    private let searchTextfield = UITextField()
    private let clearButton = UIButton()
    var onTextChange: ((String) -> Void)?
    var onClearButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "tab_bar_grey")?.cgColor
        placeholderView.layer.cornerRadius = 10
        placeholderView.backgroundColor = UIColor(named: "bg_placeholder")
        iconImageView.image = UIImage(named: "ic_search")
        clearButton.setImage(UIImage(named: "ic_close"), for: .normal)
        searchTextfield.attributedPlaceholder = NSAttributedString(
            string:"Поиск",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
        )
        searchTextfield.delegate = self
        searchTextfield.returnKeyType = .done
        searchTextfield.autocorrectionType = .no
        searchTextfield.spellCheckingType = .no
        searchTextfield.autocapitalizationType = .none
        searchTextfield.smartInsertDeleteType = .no
        searchTextfield.smartQuotesType = .no
        searchTextfield.smartDashesType = .no
        searchTextfield.becomeFirstResponder()
        clearButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    private func addSubviews() {
        addSubview(placeholderView)
        placeholderView.addSubview(iconImageView)
        placeholderView.addSubview(searchTextfield)
        placeholderView.addSubview(clearButton)
    }
    
    private func makeConstraints() {
        placeholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.size.equalTo(18)
        }
        searchTextfield.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
        }
        clearButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(searchTextfield.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.size.equalTo(20)
        }
    }
    
    @objc private func handleTap() {
        searchTextfield.text = ""
        onClearButtonTap?()
    }
    
    func hideKeyboard() {
        searchTextfield.resignFirstResponder()
    }
}

extension SearchTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        onTextChange?(newText)
        return true
    }
}
