//
//  SmallTeamView.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/21.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class SmallTeamView: UIView {
    // MARK: - Properties
    private var tagViews: [UIView] = []
    
    // MARK: - View Elements
    @IBOutlet weak var tagView: TTGTagCollectionView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.delegate = self
        tagView.dataSource = self
        tagView.alignment = .center
        tagView.horizontalSpacing = 4
        tagView.numberOfLines = 1
    }
    
    func configure(team: DefenseTeam) {
        tagViews.removeAll()
        var imageViews = Array(team.members).map(TagIconUtils.generateSmallImageView)
        while imageViews.count < 5 {
            imageViews.append(TagIconUtils.generateSmallEmptyImageView())
        }
        imageViews.reverse()
        tagViews.append(contentsOf: imageViews)
        tagView.reload()
    }
}

// MARK: - TTGTagCollectionViewDataSource
extension SmallTeamView: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension SmallTeamView: TTGTagCollectionViewDelegate {
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
    }
}
