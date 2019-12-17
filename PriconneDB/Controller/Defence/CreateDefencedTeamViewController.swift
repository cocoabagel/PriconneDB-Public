//
//  CreateDefencedTeamViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import TTGTagCollectionView
import FirebaseFirestore
import FirebaseAuth

class CreateDefencedTeamViewController: UIViewController {

    // MARK: - Properties
    private var user: User?
    private var tagViews: [UIView] = []
    private var units: [Unit] = []

    // MARK: - View Elements
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var tagCollectionView: TTGTagCollectionView! {
        didSet {
            tagCollectionView.delegate = self
            tagCollectionView.dataSource = self
            tagCollectionView.scrollView.contentInsetAdjustmentBehavior = .never
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

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard) -> CreateDefencedTeamViewController {
        return storyboard.instantiateViewController(ofType: CreateDefencedTeamViewController.self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginIfNeeded()
        setupUI()
    }
    
    func setupUI() {
        title = "防衛チーム作成"
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            if traitCollection.userInterfaceStyle == .dark {
                appearance.backgroundColor = .black
            } else {
                appearance.backgroundColor = .white
            }
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.standardAppearance = appearance
        } else {
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
        
        nextBarButtonItem.isEnabled = false
        units = RealmStore.shared.units()
        let imageViews = units.map(TagIconUtils.generateImageView)
        tagViews.append(contentsOf: imageViews)
        tagCollectionView.reload()
        
        let teamVC = TeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), units: [])
        teamVC.delegate = self
        addFullScreen(childViewController: teamVC, to: self.blurView.contentView)
        self.teamVC = teamVC
    }
}

// MARK: - Actions
extension CreateDefencedTeamViewController {
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let team = DefenseTeam(members: teamVC.units.map({ $0.toAnyObject() }).compactMap(TeamMember.init),
                               wins: [],
                               uid: user?.uid ?? "",
                               key: "")
        let vc = EditDefencedTeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), team: team)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TTGTagCollectionViewDataSource
extension CreateDefencedTeamViewController: TTGTagCollectionViewDataSource {
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(tagViews.count)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        return tagViews[Int(index)]
    }
}

// MARK: - TTGTagCollectionViewDelegate
extension CreateDefencedTeamViewController: TTGTagCollectionViewDelegate {
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
        nextBarButtonItem.isEnabled = teamVC.units.count > 0
    }
}

// MARK: - TeamViewControllerDelegate
extension CreateDefencedTeamViewController: TeamViewControllerDelegate {
    func teamViewController(_ vc: TeamViewController, didTapUnit: Unit) {
        if let index = units.firstIndex(of: didTapUnit) {
            tagViews[index].alpha = 1
        }
        
        if let index = teamVC.units.firstIndex(of: didTapUnit) {
            var units = teamVC.units
            units.remove(at: index)
            teamVC.updateUnits(units)
            nextBarButtonItem.isEnabled = teamVC.units.count > 0
        }
    }
}

// MARK: - Private
private extension CreateDefencedTeamViewController {
    func loginIfNeeded() {
        Auth.auth().addStateDidChangeListener { _, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
    }
}
