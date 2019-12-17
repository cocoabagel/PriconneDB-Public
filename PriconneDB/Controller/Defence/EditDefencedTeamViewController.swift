//
//  EditDefencedTeamViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import FirebaseFirestore

class EditDefencedTeamViewController: UIViewController {

    // MARK: - Properties
    private var editToTeam: DefenseTeam!
    private var originalTeam: DefenseTeam!
    private var heightDictionary: [Int: CGFloat] = [:]

    // MARK: - View Elements
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(EditTeamMemberCell.self)
            tableView.tableFooterView = UIView()
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        }
    }

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, team: DefenseTeam) -> EditDefencedTeamViewController {
        return storyboard.instantiateViewController(ofType: EditDefencedTeamViewController.self).then {
            $0.originalTeam = team
            if team.realm == nil {
                $0.editToTeam = team
            } else {
                $0.editToTeam = DefenseTeam(dict: team.toAnyObject())
                $0.editToTeam.key = team.key
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "防衛チーム編集"
        let saveBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    @objc func saveButtonTapped() {
        let db = Firestore.firestore()
        if originalTeam.key.isEmpty {
            // new
            db.collection("teams").addDocument(data: editToTeam.toAnyObject())
        } else {
            // update
            let lastUpdated = Date()
            RealmStore.shared.update {
                for (index, member) in originalTeam.members.enumerated() {
                    member.starRank = editToTeam.members[index].starRank
                    member.star6IconURL = editToTeam.members[index].star6IconURL
                    member.uniqueEquipment = editToTeam.members[index].uniqueEquipment
                    member.lastUpdated = lastUpdated
                }
                editToTeam.lastUpdated = lastUpdated
                originalTeam.lastUpdated = lastUpdated
            }
            db.collection("teams").document(originalTeam.key).setData(editToTeam.toAnyObject())
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension EditDefencedTeamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editToTeam.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EditTeamMemberCell
        cell.configure(member: editToTeam.members[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditDefencedTeamViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

// MARK: - EditTeamMemberCellDelegate
extension EditDefencedTeamViewController: EditTeamMemberCellDelegate {
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeStarRank: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        editToTeam.members[indexPath.row].starRank = didChangeStarRank
        if didChangeStarRank > 5 && editToTeam.members[indexPath.row].star6IconURL.isEmpty {
            let db = Firestore.firestore()
            db.collection("units")
                .whereField("name", isEqualTo: editToTeam.members[indexPath.row].name)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        log.error("Error getting documents: \(error)")
                    } else {
                        guard let unit = snapshot!.documents.compactMap(Unit.init).first else { return }
                        self.editToTeam.members[indexPath.row].star6IconURL = unit.star6IconURL
                        self.tableView.reloadData()
                    }
            }
        } else {
            tableView.reloadData()
        }
    }
    
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeUniqueEquipment: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        editToTeam.members[indexPath.row].uniqueEquipment = didChangeUniqueEquipment
    }
}
