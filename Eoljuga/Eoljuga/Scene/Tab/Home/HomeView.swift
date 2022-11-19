//
//  HomeView.swift
//  Eoljuga
//
//  Created by youtak on 2022/11/19.
//

import UIKit

import SnapKit

final class HomeView: UIView {

    lazy var feedCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.register(
            RecommendFeedCell.self,
            forCellWithReuseIdentifier: RecommendFeedCell.identifier
        )
        $0.register(
            DefaultFeedCell.self,
            forCellWithReuseIdentifier: DefaultFeedCell.identifier
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(feedCollectionView)
        feedCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, _
            -> NSCollectionLayoutSection? in

            guard let feedCellType = FeedCellType(rawValue: sectionIndex)
            else { return nil }

            let columns = feedCellType.columnCount

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupWidth = self.groupWidth(feedCellType: feedCellType)
            let groupHeight = self.groupHeight(feedCellType: feedCellType)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: groupWidth,
                heightDimension: groupHeight
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 16,
                bottom: 16,
                trailing: 16
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = self.setOrthogonal(feedCellType: feedCellType)
            return section
        }

        return layout
    }

    private func groupWidth(feedCellType: FeedCellType) -> NSCollectionLayoutDimension {
        switch feedCellType {
        case .recommend: return NSCollectionLayoutDimension.absolute(300)
        case .normal: return NSCollectionLayoutDimension.fractionalWidth(1.0)
        }
    }

    private func groupHeight(feedCellType: FeedCellType) -> NSCollectionLayoutDimension {
        switch feedCellType {
        case .recommend: return NSCollectionLayoutDimension.absolute(150)
        case .normal: return NSCollectionLayoutDimension.absolute(150)
        }
    }

    private func setOrthogonal(feedCellType: FeedCellType)
    -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch feedCellType {
        case .recommend: return .continuous
        case .normal: return .none
        }
    }
}
