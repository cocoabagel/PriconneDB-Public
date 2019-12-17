//
//  ModalViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/03/24.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import PanModal
import TTGTagCollectionView

protocol PickUnitsViewControllerDelegate: class {
    func pickUnitsViewController(_ vc: PickUnitsViewController, didPickUpUnits: [Unit])
}

class PickUnitsViewController: UIViewController {

    // MARK: - Properties
    private var tagViews: [UIView] = []
    private var units: [Unit] = []
    weak var delegate: PickUnitsViewControllerDelegate?

//    var shortFormHeight: PanModalHeight {
//        return .contentHeight(300)
//    }
//    
//    var longFormHeight: PanModalHeight {
//        return .maxHeightWithTopInset(150)
//    }
    
    // MARK: - View Elements
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var tagCollectionView: TTGTagCollectionView! {
        didSet {
            tagCollectionView.delegate = self
            tagCollectionView.dataSource = self
            tagCollectionView.alignment = .left
            tagCollectionView.horizontalSpacing = 8
            tagCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0)
            if traitCollection.userInterfaceStyle == .dark {
                tagCollectionView.backgroundColor = .black
            } else {
                tagCollectionView.backgroundColor = .white
            }
        }
    }
    private var teamVC: TeamViewController!
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
        
        units = RealmStore.shared.units()
        let imageViews = units.map(TagIconUtils.generateImageView)
        tagViews.append(contentsOf: imageViews)
        for (index, value) in units.enumerated() {
            if LocalStore.selectUnitNames().contains(value.name) {
                tagViews[index].alpha = 0.6
            }
        }
        tagCollectionView.reload()
        
        let teamVC = TeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), units: loadUnits())
        teamVC.delegate = self
        addFullScreen(childViewController: teamVC, to: self.blurView.contentView)
        self.teamVC = teamVC
    }
}

// MARK: - PanModalPresentable
extension PickUnitsViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tagCollectionView.scrollView
    }
}

// MARK: - TTGTagCollectionViewDataSource
extension PickUnitsViewController: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension PickUnitsViewController: TTGTagCollectionViewDelegate {
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return Constants.unitTagSize
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {

        var selectedUnits = teamVC.units
        if tagView.alpha == 1 {
            guard selectedUnits.count < 5 else { return }
            
            tagView.alpha = 0.6
            selectedUnits.append(units[Int(index)])
        } else {
            guard let index = selectedUnits.firstIndex(of: units[Int(index)]) else { return }

            tagView.alpha = 1
            selectedUnits.remove(at: index)
        }
        
        teamVC.updateUnits(selectedUnits)
        saveSelectUnitNames(units: teamVC.units)
        delegate?.pickUnitsViewController(self, didPickUpUnits: selectedUnits)
    }
}

// MARK: - TeamViewControllerDelegate
extension PickUnitsViewController: TeamViewControllerDelegate {
    func teamViewController(_ vc: TeamViewController, didTapUnit: Unit) {
        if let index = units.firstIndex(of: didTapUnit) {
            tagViews[index].alpha = 1
        }
        
        if let index = teamVC.units.firstIndex(of: didTapUnit) {
            var units = teamVC.units
            units.remove(at: index)
            teamVC.updateUnits(units)
            saveSelectUnitNames(units: teamVC.units)
            delegate?.pickUnitsViewController(self, didPickUpUnits: units)
        }
    }
}

// MARK: - Private
extension PickUnitsViewController {
    func saveSelectUnitNames(units: [Unit]) {
        let names = units.map({ $0.name })
        LocalStore.setSelectUnitNames(names)
    }
    
    func loadUnits() -> [Unit] {
        let names = LocalStore.selectUnitNames()
        let units = Array(RealmStore.shared.findUnitsIn(names: names).sorted(by: { $0.position < $1.position }))
        return units
    }
}
