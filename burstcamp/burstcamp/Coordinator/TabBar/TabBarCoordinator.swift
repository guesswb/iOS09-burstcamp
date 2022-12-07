//  TabCoordinator.swift
//  Eoljuga
//
//  Created by youtak on 2022/11/15.
//

import Combine
import UIKit

import Then

protocol TabBarCoordinatorProtocol: NormalCoordinator {
    var tabBarController: UITabBarController { get set }
    var currentPage: TabBarPage? { get }

    func selectPage(_ page: TabBarPage)
}

final class TabBarCoordinator: TabBarCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController = UITabBarController()
    var coordinatorPublisher = PassthroughSubject<AppCoordinatorEvent, Never>()
    var cancelBag = Set<AnyCancellable>()

    var currentPage: TabBarPage? {
        return TabBarPage.init(index: tabBarController.selectedIndex)
    }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let controllers = [TabBarPage.myPage, TabBarPage.scrapPage, TabBarPage.home]
            .sorted { $0.index < $1.index }
            .map { prepareTabController($0) }

        configureTabBarController(with: controllers)
    }

    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.index
    }

    private func configureTabBarController(with tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.home.index
        tabBarController.tabBar.backgroundColor = .background
        tabBarController.tabBar.tintColor = .main
        tabBarController.tabBar.isTranslucent = false
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .background
            tabBarController.tabBar.standardAppearance = tabBarAppearance
        }
        navigationController.viewControllers = [tabBarController]
    }

    private func configureTabBarItem(of viewController: UIViewController, with page: TabBarPage) {
        viewController.tabBarItem = UITabBarItem(
            title: page.pageTitle,
            image: UIImage(systemName: page.pageIconTitle),
            tag: page.index
        )
    }

    private func prepareTabController(_ page: TabBarPage) -> UIViewController {
        var controller: UIViewController
        switch page {
        case .home:
            controller = homeCoordinatorStart()
        case .scrapPage:
            let scrapPageViewModel = ScrapPageViewModel()
            controller = ScrapPageViewController(viewModel: scrapPageViewModel)
        case .myPage:
            controller = myPageCoordinatorStart()
        }
        configureTabBarItem(of: controller, with: page)
        return controller
    }

    private func homeCoordinatorStart() -> HomeViewController {
        let homeViewModel = HomeViewModel()
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.start(viewController: homeViewController)
        childCoordinators.append(homeCoordinator)
        return homeViewController
    }

    private func myPageCoordinatorStart() -> MyPageViewController {
        let myPageViewModel = MyPageViewModel()
        let myPageViewController = MyPageViewController(viewModel: myPageViewModel)
        let myPageCoordinator = MyPageCoordinator(navigationController: navigationController)
        myPageCoordinator.start(viewController: myPageViewController)
        childCoordinators.append(myPageCoordinator)
        return myPageViewController
    }
}
