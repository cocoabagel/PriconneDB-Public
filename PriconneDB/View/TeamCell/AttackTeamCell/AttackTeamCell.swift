//
//  AttackTeamCell.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/10/29.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import TTGTagCollectionView

protocol AttackTeamCellDelegate: class {
    func attackTeamCellLikeButtonTapped(_ cell: AttackTeamCell)
    func attackTeamCellDislikeButtonTapped(_ cell: AttackTeamCell)
}

class AttackTeamCell: UITableViewCell {

    // MARK: - Properties
    private var tagViews: [UIView] = []
    weak var delegate: AttackTeamCellDelegate?

    // MARK: - View Elements
    @IBOutlet weak var tagView: TTGTagCollectionView! {
        didSet {
            tagView.delegate = self
            tagView.dataSource = self
            tagView.alignment = .left
            tagView.horizontalSpacing = 8
            tagView.numberOfLines = 1
        }
    }
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var remarksLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(team: AttackTeam) {
        tagViews.removeAll()
        var imageViews = Array(team.members).map(TagIconUtils.generateImageView)
        while imageViews.count < 5 {
            imageViews.append(TagIconUtils.generateEmptyImageView())
        }
        imageViews.reverse()
        createdLabel.text = dateFormatter.string(from: team.created)
        likeButton.setTitle("👍 \(team.likeCount)", for: .normal)
        dislikeButton.setTitle("👎 \(team.dislikeCount)", for: .normal)
        remarksLabel.text = team.remarks
        tagViews.append(contentsOf: imageViews)
        tagView.reload()
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.attackTeamCellLikeButtonTapped(self)
    }
    
    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        delegate?.attackTeamCellDislikeButtonTapped(self)
    }

}

// MARK: - TTGTagCollectionViewDataSource
extension AttackTeamCell: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension AttackTeamCell: TTGTagCollectionViewDelegate {
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return Constants.teamUnitTagSize
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
    }
}

// MARK: - Private
private extension AttackTeamCell {
}
