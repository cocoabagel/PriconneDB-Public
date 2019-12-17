//
//  EditAttackTeamViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/03.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import FirebaseFirestore

class EditAttackTeamViewController: UIViewController {

    // MARK: - Properties
    private var parentTeam: DefenseTeam!
    private var editToAttackTeam: AttackTeam!
    private var originalAttackTeam: AttackTeam!
    private var heightDictionary: [Int: CGFloat] = [:]

    // MARK: - View Elements
    lazy var savedButtonItem = { () -> UIBarButtonItem in
        return UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveButtonTapped))
    }()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(EditTeamMemberCell.self)
            tableView.register(RemarksCell.self)
            tableView.tableFooterView = UIView()
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        }
    }

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, parentTeam: DefenseTeam, attackTeam: AttackTeam) -> EditAttackTeamViewController {
        return storyboard.instantiateViewController(ofType: EditAttackTeamViewController.self).then {
            $0.parentTeam = parentTeam
            $0.originalAttackTeam = attackTeam
            if attackTeam.realm == nil {
                $0.editToAttackTeam = attackTeam
            } else {
                $0.editToAttackTeam = AttackTeam(dict: attackTeam.toAnyObject())
            }
        }
    }
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "勝利チーム編集"
        navigationItem.rightBarButtonItems = [savedButtonItem]
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
        
    @objc func saveButtonTapped() {
        let db = Firestore.firestore()
        if originalAttackTeam.realm == nil {
            // new
            RealmStore.shared.addWinningTeamToDefensiveTeam(team: parentTeam, winTeam: editToAttackTeam)
            db.collection("teams").document(parentTeam.key).setData(parentTeam.toAnyObject())
        } else {
            // update
            let lastUpdated = Date()
            RealmStore.shared.update {
                for (index, member) in originalAttackTeam.members.enumerated() {
                    member.starRank = editToAttackTeam.members[index].starRank
                    member.star6IconURL = editToAttackTeam.members[index].star6IconURL
                    member.uniqueEquipment = editToAttackTeam.members[index].uniqueEquipment
                    member.lastUpdated = lastUpdated
                }
                editToAttackTeam.lastUpdated = lastUpdated
                originalAttackTeam.lastUpdated = lastUpdated
                originalAttackTeam.remarks = editToAttackTeam.remarks
                parentTeam.lastUpdated = lastUpdated
            }
            db.collection("teams").document(parentTeam.key).setData(parentTeam.toAnyObject())
        }

        for vc in navigationController?.viewControllers ?? [] {
            if vc.isKind(of: AttackTeamsViewController.self) {
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EditAttackTeamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editToAttackTeam.members.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if editToAttackTeam.members.count == indexPath.row {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RemarksCell
            cell.configureCell(editToAttackTeam.remarks)
            return cell
        }
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EditTeamMemberCell
        cell.configure(member: editToAttackTeam.members[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditAttackTeamViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editToAttackTeam.members.count == indexPath.row {
            let vc = NoteViewController.createWith(storyboard: UIStoryboard.storyboard(.main), noteText: editToAttackTeam.remarks)
            vc.delegate = self
            present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        }        
    }
}

// MARK: - EditTeamMemberCellDelegate
extension EditAttackTeamViewController: EditTeamMemberCellDelegate {
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeStarRank: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        editToAttackTeam.members[indexPath.row].starRank = didChangeStarRank
        if didChangeStarRank > 5 && editToAttackTeam.members[indexPath.row].star6IconURL.isEmpty {
            let db = Firestore.firestore()
            db.collection("units")
                .whereField("name", isEqualTo: editToAttackTeam.members[indexPath.row].name)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        log.error("Error getting documents: \(error)")
                    } else {
                        guard let unit = snapshot!.documents.compactMap(Unit.init).first else { return }
                        self.editToAttackTeam.members[indexPath.row].star6IconURL = unit.star6IconURL
                        self.tableView.reloadData()
                    }
            }
        } else {
            tableView.reloadData()
        }
    }
    
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeUniqueEquipment: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        editToAttackTeam.members[indexPath.row].uniqueEquipment = didChangeUniqueEquipment
    }
}

// MARK: - NoteViewControllerDelegate
extension EditAttackTeamViewController: NoteViewControllerDelegate {
    func noteViewController(_ controller: NoteViewController, didFinish text: String) {
        editToAttackTeam.remarks = text
        tableView.reloadData()
    }
}
