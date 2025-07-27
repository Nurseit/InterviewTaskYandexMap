import UIKit
import SnapKit

final class BottomSheetViewController: UIViewController {
    private let grabber = UIView()
    private let sheetView: UIView
    private var panGesture: UIPanGestureRecognizer!
    private var heightConstraint: Constraint!
    private var bottomConstraint: Constraint!
    private var currentHeight: CGFloat = 0
    var onDismiss: (() -> Void)?
    var willDismiss: (() -> Void)?

    init(sheetView: UIView) {
        self.sheetView = sheetView
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        commonInit()
        addSubviews()
        addConstraint()
        setupGesture()
        animateIn()
    }

    private func commonInit() {
        sheetView.layer.cornerRadius = 8
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        sheetView.backgroundColor = .white
        grabber.layer.cornerRadius = 2.5
        grabber.backgroundColor = UIColor(named: "grabber_grey")
    }
    
    private func addSubviews() {
        view.addSubview(sheetView)
        sheetView.addSubview(grabber)
    }
    
    private func addConstraint() {
        grabber.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        
        sheetView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        sheetView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: view)

        if gesture.state == .ended && velocity.y > 100 {
            dismissSheet()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        
        if !sheetView.frame.contains(location) {
            dismissSheet()
        }
    }

    private func animateIn() {
        sheetView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        UIView.animate(withDuration: 0.3) {
            self.sheetView.transform = .identity
        }
    }

    func dismissSheet() {
        willDismiss?()
        UIView.animate(withDuration: 0.3, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: self?.onDismiss)
        })
    }
}
