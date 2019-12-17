//
//  TagIconUtils.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

public struct TagIconUtils {
    
    public static func generateImageView(with member: TeamMember) -> UIImageView {
        let imageView = UIImageView(image: nil)
        imageView.kf.setImage(with: URL(string: member.iconURL),
                              placeholder: UIImage(named: "Placeholder"),
                              options: [.transition(.fade(0.2))])
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.teamUnitTagSize.width, height: Constants.teamUnitTagSize.height)
        imageView.sizeToFit()
        
        // rating
        let ratingControlView = UIView.load(SmallRatingView.self)
        ratingControlView.ratingControl.maxRating = member.starRank
        ratingControlView.ratingControl.rating = member.starRank
        imageView.addSubview(ratingControlView)
        ratingControlView.translatesAutoresizingMaskIntoConstraints = false
        ratingControlView.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: -4).isActive = true
        ratingControlView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
        
        if member.uniqueEquipment {
            let uniqueEquipmentIconImageView = UIImageView(image: UIImage(named: "uniqueEquipment"))
            uniqueEquipmentIconImageView.sizeToFit()
            imageView.addSubview(uniqueEquipmentIconImageView)
            uniqueEquipmentIconImageView.translatesAutoresizingMaskIntoConstraints = false
            uniqueEquipmentIconImageView.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -2).isActive = true
            uniqueEquipmentIconImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -1).isActive = true
        }
        
        return imageView
    }
    
    public static func generateImageView(with unit: Unit) -> UIImageView {
        let imageView = UIImageView(image: nil)
        imageView.kf.setImage(with: URL(string: unit.iconURL),
                              placeholder: UIImage(named: "Placeholder"),
                              options: [.transition(.fade(0.2))])
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.unitTagSize.width, height: Constants.unitTagSize.height)
        imageView.sizeToFit()
        
        return imageView
    }
    
    public static func generateEmptyImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "Placeholder"))
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.teamUnitTagSize.width, height: Constants.teamUnitTagSize.height)
        imageView.sizeToFit()
        
        return imageView
    }
    
    public static func generateSmallImageView(with member: TeamMember) -> UIImageView {
        let imageView = UIImageView(image: nil)
        imageView.kf.setImage(with: URL(string: member.iconURL),
                              placeholder: UIImage(named: "Placeholder"),
                              options: [.transition(.fade(0.2))])
        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        imageView.sizeToFit()
        
        return imageView
    }
    
    public static func generateSmallEmptyImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "Placeholder"))
        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        imageView.sizeToFit()
        
        return imageView
    }
}
