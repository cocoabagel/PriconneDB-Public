//
//  DefenseTeamCell.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class TeamCell: UITableViewCell {

    // MARK: - Properties
    private var tagViews: [UIView] = []
    
    // MARK: - View Elements
    @IBOutlet weak var tagView: TTGTagCollectionView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.delegate = self
        tagView.dataSource = self
        tagView.alignment = .left
        tagView.horizontalSpacing = 8
        tagView.numberOfLines = 1
    }

    func configure(team: DefenseTeam) {
        tagViews.removeAll()
        var imageViews = Array(team.members)
            .map({ URL(string: $0.iconURL) })
            .map(TagIconUtils.generateImageView)
        while imageViews.count < 5 {
            imageViews.append(TagIconUtils.generateImageView(with: nil))
        }
        imageViews.reverse()
        tagViews.append(contentsOf: imageViews)
        tagView.reload()
    }
}

// MARK: - TTGTagCollectionViewDataSource
extension TeamCell: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension TeamCell: TTGTagCollectionViewDelegate {
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return Constants.tagSize
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
    }
}

// MARK: - Private
extension TeamCell {
}
