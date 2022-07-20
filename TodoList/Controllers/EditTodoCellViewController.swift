//
//  EditTodoCellViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 05.07.2022.
//

import UIKit
import RealmSwift
import UserNotifications

class EditTodoCellViewController: UIViewController {
	
	let realm: Realm
	var item: TodoItem
		
	let notifications = Notifications()
			
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
		
		view.backgroundColor = .secondarySystemBackground
		setupToHideKeyboardOnTapOnView()
		
		
		view.addSubview(dissmissViewButton)
		view.addSubview(textField)
		view.addSubview(changeTitleLabel)
		view.addSubview(selectDateStack)
		
		NSLayoutConstraint.activate([
			dissmissViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			dissmissViewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
			dissmissViewButton.widthAnchor.constraint(equalToConstant: 30),
			dissmissViewButton.heightAnchor.constraint(equalToConstant: 30),
			
			changeTitleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 10),
			changeTitleLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
			changeTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
			changeTitleLabel.heightAnchor.constraint(equalToConstant: 30),
			
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			textField.topAnchor.constraint(equalTo: changeTitleLabel.bottomAnchor, constant: 5),
			textField.heightAnchor.constraint(equalToConstant: 60),
			
			selectDateStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
			selectDateStack.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
			selectDateStack.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
			selectDateStack.heightAnchor.constraint(equalToConstant: 60)
		])
    }
	
	private var changeTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Rename category:"
		label.font = UIFont.systemFont(ofSize: 18)
		label.textColor = .darkGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var textField: UITextField = {
		let textField = UITextField()
		textField.text = item.name
		textField.backgroundColor = .systemBackground
		textField.font = UIFont.systemFont(ofSize: 22)
		textField.textColor = .label
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.makeBorderedWithShadow()
		textField.setLeftPaddingPoints(20)
		return textField
	}()
	
	lazy private var dissmissViewButton: UIButton = {
		let buttonImage = UIImage(systemName: "x.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
		$0.setImage(buttonImage, for: .normal)
		$0.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
		$0.translatesAutoresizingMaskIntoConstraints = false
	return $0 }(UIButton(type: .system))
	
	lazy private var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .dateAndTime
		datePicker.layer.opacity = item.dateToRemind == nil ? 0 : 1
		datePicker.addTarget(nil, action: #selector(dateChosen), for: .valueChanged)
		return datePicker
	}()
	
	private var dateSwitchLabel: UILabel = {
		let label = UILabel()
		label.text = "Remind"
		label.textAlignment = .right
		label.font = UIFont.systemFont(ofSize: 22)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	lazy private var dateSwitch: UISwitch = {
		let switcher = UISwitch()
		switcher.thumbTintColor = K.CustomColors.iconColor
		switcher.isOn = item.dateToRemind == nil ? false : true
		switcher.addTarget(nil, action: #selector(dateSwitchStateChanged), for: .valueChanged)
		return switcher
	}()
	
	lazy private var selectDateStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [dateSwitchLabel, dateSwitch, datePicker])
		stack.distribution = .fillProportionally
		stack.spacing = 5
		stack.alignment = .center
		stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
		stack.isLayoutMarginsRelativeArrangement = true
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.backgroundColor = .systemBackground
		stack.layer.cornerRadius = 10
		return stack
	}()
	
	@objc func dateChosen() {
		let date = datePicker.date
//		
		guard date.timeIntervalSinceNow > 0 else { print("Date in past"); return }
		notifications.notificationRequest()
		
		let identifier = notifications.addNewNotification(for: item, with: datePicker.date)
		//write new notification parameters
		do {
			try realm.write {
				item.notificationIdentifier = identifier
				item.dateToRemind = datePicker.date
			}
		} catch {
			print("Failed to write to Realm database \(error)")
		}
	}
	
	@objc func dateSwitchStateChanged() {
		if dateSwitch.isOn {
			UIView.animate(withDuration: 0.2, delay: 0) {
				self.datePicker.layer.opacity = 1
			}
		} else {
			UIView.animate(withDuration: 0.2, delay: 0) {
				self.datePicker.layer.opacity = 0
			}
			// remove notification from notification queue
			if let id = item.notificationIdentifier {
				notifications.unscheduleNotification(with: id)
			}
			
			do {
				try realm.write {
					item.dateToRemind = nil
					item.notificationIdentifier = nil
				}
			} catch {
				print("Failed to write to Realm database \(error)")
			}
		}
	}
	
	@objc func dismissView() {
		dismiss(animated: true)
	}
}

extension EditTodoCellViewController: UITextFieldDelegate {
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
