//
//  TeamViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import TTGTagCollectionView
import Then

protocol TeamViewControllerDelegate: class {
    func teamViewController(_ vc: TeamViewController, didTapUnit: Unit)
}

extension TeamViewControllerDelegate {
    func teamViewController(_ vc: TeamViewController, didTapUnit: Unit) {}
}

class TeamViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: TeamViewControllerDelegate?
    private(set) var units: [Unit] = [] {
        didSet {
//            updateUI()
        }
    }
    
    private var tagViews: [UIView] = []

    // MARK: - View Elements
    @IBOutlet weak var tagView: TTGTagCollectionView!

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, units: [Unit]) -> TeamViewController {
        return storyboard.instantiateViewController(ofType: TeamViewController.self).then {
            $0.units = units
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tagView.delegate = self
        tagView.dataSource = self
        tagView.alignment = .left
        tagView.horizontalSpacing = 8
        tagView.alignment = .center
        tagView.numberOfLines = 1
        
        updateUI()
    }
    
    func updateUnits(_ units: [Unit]) {
        guard units.count <= 5 else { return }
        self.units = units.sorted(by: { $0.position < $1.position })
        updateUI()
    }
    
    func updateUI() {
        tagViews.removeAll()
        var imageViews = units.map(TagIconUtils.generateImageView)
        imageViews.reverse()
        tagViews.append(contentsOf: imageViews)
        tagView.reload()
    }
}

// MARK: - TTGTagCollectionViewDataSource
extension TeamViewController: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension TeamViewController: TTGTagCollectionViewDelegate {
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return Constants.teamUnitTagSize
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
        delegate?.teamViewController(self, didTapUnit: units.reversed()[Int(index)])
    }
}
