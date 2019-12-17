//
//  AttackTeamsViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/03.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import Then
import FirebaseFirestore
import RealmSwift
import ViewAnimator

class AttackTeamsViewController: UIViewController {
    
    private var team: DefenseTeam!
    private var attackTeams: [AttackTeam] = []
    private var token: NotificationToken!
    private var heightDictionary: [Int: CGFloat] = [:]
    private var firstTime: Bool = true

    // MARK: - View Elements
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(AttackTeamCell.self)
            tableView.register(CreatedDateCell.self)
            tableView.tableFooterView = UIView()
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    private let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, team: DefenseTeam) -> AttackTeamsViewController {
        return storyboard.instantiateViewController(ofType: AttackTeamsViewController.self).then {
            $0.team = team
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTeam()
    }
    
    func setupUI() {
        title = "勝利"
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
        
        navigationItem.titleView = UIView.load(SmallTeamView.self).then {
            $0.configure(team: team)
        }

        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    func loadTeam() {
        token = team.wins
            .sorted(byKeyPath: "lastUpdated", ascending: false)
            .sorted(byKeyPath: "likeCount", ascending: false)
            .observe { changes in
                
            if self.team.wins.isInvalidated {
                self.attackTeams = []
                self.tableView.reloadData()
            } else {
                switch changes {
                case .initial(let results):
                    self.attackTeams = Array(results)
                case .update(let results, _, _, _):
                    self.attackTeams = Array(results)
                default:
                    break
                }
                self.tableView.reloadData()
                if self.firstTime {
                    self.firstTime = false
                    self.animate()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
        animate()
    }

    func animate() {
        UIView.animate(views: self.tableView.visibleCells, animations: self.animations)
    }
    
    @IBAction func addAttackTeam(_ sender: Any) {
        let vc = CreateAttackTeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), parentTeam: team)
        navigationController?.pushViewController(vc, animated: true)        
    }
}

// MARK: - UITableViewDataSource
extension AttackTeamsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attackTeams.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if attackTeams.count == indexPath.row {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CreatedDateCell
            cell.dateLabel.text = dateFormatter.string(from: team.created)
            return cell
        }
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AttackTeamCell
        cell.configure(team: attackTeams[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AttackTeamsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard attackTeams.count != indexPath.row else { return nil }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let index = team.wins.index(of: attackTeams[indexPath.row]) else { return }
        let vc = EditAttackTeamViewController.createWith(storyboard: UIStoryboard.storyboard(.main), parentTeam: team, attackTeam: team.wins[index])
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            guard let index = self.team.wins.index(of: self.attackTeams[indexPath.row]) else {
                completionHandler(false)
                return
            }
            let alert = UIAlertController(title: "確認", message: "本当に削除してもよろしいですか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "はい", style: .destructive) { _ in
                TapticEngine.impact.feedback(.heavy)
                RealmStore.shared.deleteWinningTeamFrom(team: self.team, at: index)
                let db = Firestore.firestore()
                db.collection("teams").document(self.team.key).setData(self.team.toAnyObject())
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
}

// MARK: - AttackTeamCellDelegate
extension AttackTeamsViewController: AttackTeamCellDelegate {
    func attackTeamCellLikeButtonTapped(_ cell: AttackTeamCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let index = self.team.wins.index(of: attackTeams[indexPath.row]) else { return }
        TapticEngine.impact.feedback(.medium)
        updateAtackTeamLikeCount(at: index)
    }
    
    func attackTeamCellDislikeButtonTapped(_ cell: AttackTeamCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let index = self.team.wins.index(of: attackTeams[indexPath.row]) else { return }
        TapticEngine.impact.feedback(.medium)
        updateAtackTeamDislikeCount(at: index)
    }
}

extension AttackTeamsViewController {

    func updateAtackTeamLikeCount(at index: Int) {
        let lastUpdated = Date()
        RealmStore.shared.update {
            self.team.wins[index].likeCount += 1
            self.team.wins[index].recommend = self.team.wins[index].likeCount > self.team.wins[index].dislikeCount
            self.team.wins[index].lastUpdated = lastUpdated
            self.team.lastUpdated = lastUpdated
        }
        let db = Firestore.firestore()
        db.collection("teams").document(self.team.key).setData(self.team.toAnyObject())
    }
    
    func updateAtackTeamDislikeCount(at index: Int) {
        let lastUpdated = Date()
        RealmStore.shared.update {
            self.team.wins[index].dislikeCount += 1
            self.team.wins[index].recommend = self.team.wins[index].likeCount > self.team.wins[index].dislikeCount
            self.team.wins[index].lastUpdated = lastUpdated
            self.team.lastUpdated = lastUpdated
        }
        let db = Firestore.firestore()
        db.collection("teams").document(self.team.key).setData(self.team.toAnyObject())
    }

}
