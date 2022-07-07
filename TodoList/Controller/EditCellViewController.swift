//
//  EditCellViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 05.07.2022.
//

import UIKit

class EditCellViewController: UIViewController {
	
	var item: Item!
	
	var complition: (Item) -> Void = { _ in}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .white
		setupToHideKeyboardOnTapOnView()
		
		let textField = UITextField()
		textField.text = item.title
		textField.backgroundColor = .lightGray
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		
		view.addSubview(textField)
		
		NSLayoutConstraint.activate([
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			textField.heightAnchor.constraint(equalToConstant: 60)
		])
    }
}

extension EditCellViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		item.title = text
		complition(item)
		print("End edit")
	}
}
