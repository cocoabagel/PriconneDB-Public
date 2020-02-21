//
//  HomeViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/03/24.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import PanModal
import TTGTagCollectionView
import FirebaseFirestore
import FirebaseAuth
import Kingfisher
import KingfisherWebP
import JJFloatingActionButton
import ViewAnimator

class HomeViewController: UIViewController {

    // MARK: - Properties
    private var user: User? {
        didSet {
            self.toggleLoginButton()
        }
    }
    private var units: [Unit] = []
    private var teams: [DefenseTeam] = []
    private var firstTime: Bool = true
    
    // MARK: - View Elements
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(TeamCell.self)
            tableView.tableFooterView = UIView()
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    private let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loginIfNeeded()
        fetchUnits()
        fetchTeams()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
        animate()
    }
    
    func setupUI() {
        // navbar
        title = "防衛"
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
        // floating button
        let actionButton = JJFloatingActionButton()
        actionButton.addItem(title: "検索", image: UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)) { _ in
            guard let vc = self.storyboard?.instantiateViewController(ofType: PickUnitsViewController.self) else { return }
            vc.delegate = self
            self.presentPanModal(vc)
        }
        actionButton.buttonColor = UIColor(hex: "FE8697")
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        toggleLoginButton()
    }
    
    func animate() {
        UIView.animate(views: self.tableView.visibleCells, animations: self.animations)
    }
}

// MARK: - Actions
extension HomeViewController {
    func toggleLoginButton() {
        // WIP
        if self.user != nil {
            let logoutButtonItem = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(logout))
            navigationItem.leftBarButtonItems = [logoutButtonItem]
        } else {
            let loginButtonItem = UIBarButtonItem(title: "ログイン", style: .plain, target: self, action: #selector(presentLogin))
            navigationItem.leftBarButtonItems = [loginButtonItem]
        }
    }
    
    @objc func presentLogin() {
        guard let vc = storyboard?.instantiateViewController(ofType: LoginViewController.self) else { return }
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            teams = RealmStore.shared.filterDefensedTeamsIn(names: LocalStore.selectUnitNames(), uid: self.user?.uid ?? "")
            tableView.reloadData()
            animate()
        } catch let error {
            log.error("Auth sign out failed: \(error)")
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension HomeViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let cellPosition = tableView.convert(location, from: view)
        guard let indexPath = tableView.indexPathForRow(at: cellPosition) else { return nil }
        
        let attackTeamVC = AttackTeamsViewController.createWith(storyboard: UIStoryboard.storyboard(.main), team: teams[indexPath.row])
        attackTeamVC.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.size.height * 0.5)
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        previewingContext.sourceRect = view.convert(cell.frame, to: tableView)
        
        return attackTeamVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TeamCell
        cell.configure(team: teams[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let attackTeamVC = AttackTeamsViewController.createWith(storyboard: UIStoryboard.storyboard(.main), team: teams[indexPath.row])
        navigationController?.pushViewController(attackTeamVC, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let team = teams[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (_, _, completionHandler) in
            let alert = UIAlertController(title: "確認", message: "本当に削除してもよろしいですか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "はい", style: .destructive) { _ in
                TapticEngine.impact.feedback(.heavy)
                let db = Firestore.firestore()
                db.collection("teams").document(team.key).delete()
                completionHandler(true)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let team = teams[indexPath.row]
        let editAction = UIContextualAction(style: .normal, title: "編集") { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let vc = EditDefencedTeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), team: team)
            self.navigationController?.pushViewController(vc, animated: true)

            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
}

// MARK: - PickUnitsViewControllerDelegate
extension HomeViewController: PickUnitsViewControllerDelegate {
    func pickUnitsViewController(_ vc: PickUnitsViewController, didPickUpUnits: [Unit]) {
        teams = RealmStore.shared.filterDefensedTeamsIn(names: LocalStore.selectUnitNames(), uid: self.user?.uid ?? "")
        tableView.reloadData()
        log.info("number of teams: \(teams.count)")
    }
}

// MARK: - LoginViewControllerDelegate
extension HomeViewController: LoginViewControllerDelegate {
    func loginViewControllerDidLogin(_ vc: LoginViewController) {
        teams = RealmStore.shared.filterDefensedTeamsIn(names: LocalStore.selectUnitNames(), uid: self.user?.uid ?? "")
        tableView.reloadData()
        animate()
    }
}

private extension HomeViewController {
    func loginIfNeeded() {
        Auth.auth().addStateDidChangeListener { _, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
    }
    
    func fetchUnits() {
        let db = Firestore.firestore()
        db.collection("units")
            .order(by: "position", descending: false)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    log.error("Error getting documents: \(error)")
                } else {
                    let units = snapshot!.documents.compactMap(Unit.init)
                    log.debug(units)
                    RealmStore.shared.addOrUpdateOrDelete(units: units)
                    log.info("number of units: \(units.count)")
                    self.units = RealmStore.shared.units()
                    self.tableView.reloadData()
               }
        }
    }
    
    func fetchTeams() {
        let db = Firestore.firestore()
        db.collection("teams")
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    log.error("Error getting documents: \(error)")
                } else {
                    let teams = snapshot!.documents.compactMap(DefenseTeam.init)
                    log.info("number of teams: \(teams.count)")
                    RealmStore.shared.addOrUpdateOrDelete(defensedTeams: teams)
                    self.teams = RealmStore.shared.filterDefensedTeamsIn(names: LocalStore.selectUnitNames(), uid: self.user?.uid ?? "")
                    self.tableView.reloadData()
                    if self.firstTime {
                        self.firstTime = false
                        self.animate()
                    }
                }
        }
    }
}
