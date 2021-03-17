//
//  SearchBarView.swift
//  SearchBar
//
//  Created by Melki on 17/03/21.
//  Copyright © 2019 Melki. All rights reserved.
//

import UIKit


@objc protocol SearchBarViewDelegate: NSObjectProtocol {
    func searchByString(searchText : String)
    func clearSearch()
}

class SearchBarView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var delegate: SearchBarViewDelegate?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var clearTextBtn: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    @IBAction func actionDidClearText(_ sender: UIButton) {
        clearTxtField()
        delegate?.clearSearch()
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchTxtField.text = ""
        clearTextBtn.setImage(UIImage.init(named: "new_search_icon"), for: .normal)
        searchTxtField.layer.masksToBounds = true
        searchTxtField.layer.borderColor = UIColor.init(named:"themeColor")?.cgColor
        searchTxtField.layer.borderWidth = 1.5
        searchTxtField.layer.cornerRadius = 4.0
        searchTxtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: searchTxtField.frame.height))
        searchTxtField.leftViewMode = .always
        searchTxtField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: searchTxtField.frame.height))
        searchTxtField.rightViewMode = .always
        searchTxtField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        searchTxtField.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named:"themeColor") as Any])
    }
    public func setTitle(title:String) {
        searchTxtField.placeholder = title
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if(textField.text?.isEmpty ?? true) {
            clearTxtField()
        }
        else {
            activateTextField()
        }
        delegate?.searchByString(searchText: (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
    }
    private func clearTxtField() {
        searchTxtField.text = ""
        clearTextBtn.setImage(UIImage.init(named: "new_search_icon"), for: .normal)
    }
    private func activateTextField() {
        clearTextBtn.setImage(UIImage.init(systemName: "multiply.circle.fill"), for: .normal)
    }
    public func clearSearchText() {
        clearTxtField()
    }
    
}
extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}

@IBDesignable
class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}
