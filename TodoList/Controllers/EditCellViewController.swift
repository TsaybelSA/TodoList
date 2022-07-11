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
		
		view.addSubview(dissmissViewButton)
		view.addSubview(textField)
		
		NSLayoutConstraint.activate([
			dissmissViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			dissmissViewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
			dissmissViewButton.widthAnchor.constraint(equalToConstant: 30),
			dissmissViewButton.heightAnchor.constraint(equalToConstant: 30),
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
			textField.heightAnchor.constraint(equalToConstant: 60)
		])
    }
	
	lazy private var textField: UITextField = {
		let textField = UITextField()
		textField.text = item.title
		textField.backgroundColor = .lightGray
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.makeBorderedWithShadow()
		textField.setLeftPaddingPoints(10)
		textField.font = UIFont.systemFont(ofSize: 22)
		textField.delegate = self
		return textField
	}()
	
	lazy private var dissmissViewButton: UIButton = {
		let button = UIButton(type: .system)
		let buttonImage = UIImage(systemName: "x.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
		button.setImage(buttonImage, for: .normal)
		button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	@objc func dismissView() {
		dismiss(animated: true)
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
