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
