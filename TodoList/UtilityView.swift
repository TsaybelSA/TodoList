//
//  UtilityView.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import Foundation
import UIKit

extension UIView {
	func setConstraintsTo(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat) -> Self {
		
		return self
	}
}

struct K {
	struct Colors {
		static let lightBlue = UIColor(named: "lightBlue")
	}
}

extension UIViewController {
	func setupToHideKeyboardOnTapOnView() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(UIViewController.dismissKeyboard))

		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}

extension UITextField {
	func makeBorderedWithShadow(cornerRadius: CGFloat? = nil) {
		self.borderStyle = .none
		self.layer.masksToBounds = false
		self.layer.cornerRadius = cornerRadius ?? 10
		self.layer.backgroundColor = UIColor.white.cgColor
		self.layer.borderColor = UIColor.clear.cgColor
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: 0)
		self.layer.shadowOpacity = 0.2
		self.layer.shadowRadius = 8
	}
}

extension UITextField {
	func setLeftPaddingPoints(_ amount:CGFloat){
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
		self.leftView = paddingView
		self.leftViewMode = .always
	}
	func setRightPaddingPoints(_ amount:CGFloat) {
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
		self.rightView = paddingView
		self.rightViewMode = .always
	}
}
