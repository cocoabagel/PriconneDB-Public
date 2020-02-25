//
//  EditDefensedTeamCell.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/03.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

protocol EditTeamMemberCellDelegate: class {
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeStarRank: Int)
    func editTeamMemberCell(_ cell: EditTeamMemberCell, didChangeUniqueEquipment: Bool)
}

class EditTeamMemberCell: UITableViewCell {

    weak var delegate: EditTeamMemberCellDelegate?

    // MARK: - View Elements
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starRatingControl: STRatingControl!
    @IBOutlet weak var onUniqueEquipment: UISwitch!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        starRatingControl.delegate = self
//        starRatingControl.isUserInteractionEnabled = false
    }
    
    func configure(member: TeamMember) {
        let iconURL = URL(string: member.iconURL)
        iconImageView.kf.setImage(with: iconURL, placeholder: UIImage(named: "Placeholder"), options: [.transition(.fade(0.2))])
        nameLabel.text = member.name
        starRatingControl.rating = member.starRank
        onUniqueEquipment.isOn = member.uniqueEquipment
    }
    
    @IBAction func uniqueEquipmentSwitchChanged(_ sender: UISwitch) {
        delegate?.editTeamMemberCell(self, didChangeUniqueEquipment: sender.isOn)
    }
}

// MARK: - STRatingControlDelegate
extension EditTeamMemberCell: STRatingControlDelegate {
    func didSelectRating(_ control: STRatingControl, rating: Int) {
        delegate?.editTeamMemberCell(self, didChangeStarRank: rating)
    }
}
