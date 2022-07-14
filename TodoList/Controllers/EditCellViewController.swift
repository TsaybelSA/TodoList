//
//  EditCellViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 05.07.2022.
//

import UIKit
import RealmSwift

class EditCellViewController: UIViewController {
	
	let realm: Realm
	var item: TodoItem
		
	required init(cellItem: TodoItem, realmConfiguration: Realm.Configuration) {
		self.realm = try! Realm(configuration: realmConfiguration)
		self.item = cellItem
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

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
		$0.text = item.name
		$0.backgroundColor = .lightGray
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.makeBorderedWithShadow()
		$0.setLeftPaddingPoints(10)
		$0.font = UIFont.systemFont(ofSize: 22)
		$0.delegate = self
	return $0 }(UITextField())
	
	lazy private var dissmissViewButton: UIButton = {
		let buttonImage = UIImage(systemName: "x.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
		$0.setImage(buttonImage, for: .normal)
		$0.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
		$0.translatesAutoresizingMaskIntoConstraints = false
	return $0 }(UIButton(type: .system))
	
	@objc func dismissView() {
		dismiss(animated: true)
	}
}

extension EditCellViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		do {
			try realm.write {
				item.name = text
			}
		} catch {
			print("Error deleting item from Realm database \(error)")
		}
		print("End edit")
	}
}
