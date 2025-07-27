import UIKit
import SnapKit

final class TabBarViewController: UITabBarController {

    private let customTabBarBackgroundView = UIView()

    override func viewDidLoad() {
            super.viewDidLoad()
            setupViewControllers()
        setupCustomTabBarBackground()
            setupTabBarAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCustomTabBarBackground()
    }

    private func setupViewControllers() {
        let bookmarksVC = BookmarkViewController()
        let bookmaprksPresenter = BookmarkPresenter()
        bookmarksVC.presenter = bookmaprksPresenter
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
            bookmarksNav.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_bookmark"),
                selectedImage: UIImage(named: "ic_bookmark")
            )
        let mapVC = MapViewController()
        let mapPresenter = MapPresenter(view: mapVC)
        mapVC.presenter = mapPresenter
        mapVC.view.backgroundColor = .white
        mapVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "ic_location")?
                .withTintColor(UIColor(named: "tab_bar_grey")!),
            selectedImage: UIImage(named: "ic_location")
        )

        viewControllers = [
            bookmarksNav,
            mapVC
        ]
        
        selectedIndex = 1
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .black                      // Цвет активной иконки
        tabBar.unselectedItemTintColor = UIColor(named: "tab_bar_grey")   // Цвет неактивных иконок
    }
    
    private func setupCustomTabBarBackground() {
        view.addSubview(customTabBarBackgroundView)
        view.bringSubviewToFront(tabBar)

        customTabBarBackgroundView.backgroundColor = .white
        customTabBarBackgroundView.layer.cornerRadius = 8
        customTabBarBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        customTabBarBackgroundView.layer.shadowColor = UIColor(named: "tab_bar_shadow")?.cgColor
        customTabBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        customTabBarBackgroundView.layer.shadowOpacity = 1
        customTabBarBackgroundView.layer.shadowRadius = 3
        customTabBarBackgroundView.layer.masksToBounds = false
    }
    
    
    
    private func positionCustomTabBarBackground() {
        let height: CGFloat = 80
        let bottomInset = view.safeAreaInsets.bottom

        customTabBarBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(height)
            make.bottom.equalToSuperview()
        }

        tabBar.frame = CGRect(
            x: 10,
            y: view.frame.height - height,
            width: view.frame.width - 20,
            height: height + bottomInset
        )

        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
    }
}

