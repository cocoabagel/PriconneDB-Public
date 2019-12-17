//
//  STRatingControl.swift
//  STRatingBarExample
//
//  Created by Shukhrat Tursunov on 12/29/15.
//  Copyright © 2015 Shukhrat Tursunov. All rights reserved.
//

import UIKit

@objc public protocol STRatingControlDelegate {
    @objc optional func didSelectRating(_ control: STRatingControl, rating: Int)
}

@IBDesignable

open class STRatingControl: UIView {
    
    // MARK: Properties
    
    @IBInspectable open var rating: Int = 0 {
        didSet {
            if rating < 0 {
                rating = 0
            }
            if rating > maxRating {
                rating = maxRating
            }
            setNeedsLayout()
        }
    }
    @IBInspectable open var maxRating: Int = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open var filledStarImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var filledSixStarImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var emptyStarImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var spacing: Int = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak open var delegate: STRatingControlDelegate?
    
    fileprivate var ratingButtons = [UIButton]()
    fileprivate var buttonHeight: Int {
        return Int(self.frame.height)
    }
    fileprivate var width: Int {
        return ((buttonHeight + spacing) * maxRating) - spacing
    }
    
    // MARK: Initialization
    
    func initRate() {
        if ratingButtons.count == 0 {
            for i in 0..<maxRating {
                let button = UIButton()
                button.setImage(emptyStarImage, for: .normal)
                if i < 5 {
                    button.setImage(filledStarImage, for: .selected)
                    button.setImage(filledStarImage, for: [.highlighted, .selected])
                } else {
                    button.setImage(filledSixStarImage, for: .selected)
                    button.setImage(filledSixStarImage, for: [.highlighted, .selected])
                }
                button.isUserInteractionEnabled = false
                button.adjustsImageWhenHighlighted = false
                ratingButtons += [button]
                addSubview(button)
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.initRate()
        
        // Set the button's width and height to a square the size of the frame's height.
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonHeight + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: buttonHeight)
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
    }
    
    // MARK: Gesture recognizer
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleStarTouches(touches, withEvent: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleStarTouches(touches, withEvent: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didSelectRating?(self, rating: self.rating)
    }
    
    func handleStarTouches(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            
            if position.x > -50 && position.x < CGFloat(width + 50) {
                ratingButtonSelected(position)
            }
        }
    }
    
    func ratingButtonSelected(_ position: CGPoint) {
        for (index, button) in ratingButtons.enumerated() {
            if position.x > button.frame.minX {
                self.rating = index + 1
            } else if position.x < 0 {
                self.rating = 0
            }
        }
    }
    
}
