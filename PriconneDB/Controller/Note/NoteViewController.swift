//
//  RemarksViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/06/07.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: class {
    func noteViewController(_ controller: NoteViewController, didFinish text: String)
}

class NoteViewController: UIViewController {
    static let placeholderText: String = "コメントです、タップして編集できます"

    // MARK: - Properties
    private var noteText: String = ""
    weak var delegate: NoteViewControllerDelegate?

    // MARK: - View Elements
    lazy var doneButtonItem = { () -> UIBarButtonItem in
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonTapped(_:)))
    }()

    @IBOutlet weak var textView: UITextView!

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, noteText: String = "") -> NoteViewController {
        return storyboard.instantiateViewController(ofType: NoteViewController.self).then {
            $0.noteText = noteText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "メモ"
        navigationItem.setRightBarButtonItems([doneButtonItem], animated: true)
        textView.delegate = self
        initializeTextView()
    }
    
}

// MARK: - Actions
extension NoteViewController {
    
    @objc func closeButtonTapped(_ sender: Any) {
        let text = textView.text == NoteViewController.placeholderText ? "" : textView.text!
        delegate?.noteViewController(self, didFinish: text)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            setTextViewEditintStyle()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setTextViewEmptyStyle()
        }
    }
}

// MARK: - Private
private extension NoteViewController {
    func initializeTextView() {
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        if noteText.isEmpty {
            setTextViewEmptyStyle()
        } else {
            textView.text = noteText
        }
    }
    
    func setTextViewEmptyStyle() {
        textView.text = NoteViewController.placeholderText
        textView.textColor = UIColor.lightGray
    }
    
    func setTextViewEditintStyle() {
        textView.text = nil
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                textView.textColor = UIColor.white
            } else {
                textView.textColor = UIColor.black
            }
        } else {
            textView.textColor = UIColor.black
        }
    }
}
