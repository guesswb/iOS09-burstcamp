//
//  HomeCoordinator.swift
//  burstcamp
//
//  Created by youtak on 2022/12/06.
//

import Combine
import UIKit

protocol HomeCoordinatorProtocol: TabBarChildCoordinator {
    func moveToFeedDetail(feed: Feed)
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var cancelBag = Set<AnyCancellable>()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension HomeCoordinator {
    func start(viewController: UIViewController) {
        guard let homeViewController = viewController as? HomeViewController else {
            return
        }

        navigationController.viewControllers = [homeViewController]

        homeViewController.coordinatorPublisher
            .sink { [weak self] event in
                switch event {
                case .moveToFeedDetail(let feed):
                    self?.moveToFeedDetail(feed: feed)
                }
            }
            .store(in: &cancelBag)
    }

    func moveToFeedDetail(feed: Feed) {
        let feedDetailViewController = prepareFeedDetailViewController(feed: feed)

        self.navigationController.pushViewController(feedDetailViewController, animated: true)
    }

    func prepareFeedDetailViewController(feed: Feed) -> FeedDetailViewController {
        let feedDetailViewModel = FeedDetailViewModel(feed: feed)
        let feedScrapViewModel = FeedScrapViewModel(feedUUID: feed.feedUUID)
        let feedDetailViewController = FeedDetailViewController(
            feedDetailViewModel: feedDetailViewModel,
            feedScrapViewModel: feedScrapViewModel
        )
        return feedDetailViewController
    }
}
