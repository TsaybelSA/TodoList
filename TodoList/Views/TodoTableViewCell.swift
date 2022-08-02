//
//  TodoTableViewCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import UIKit
import RealmSwift

class TodoTableViewCell: UITableViewCell {
	
	var item = TodoItem()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(selectionImage)
		contentView.addSubview(infoButton)
		contentView.addSubview(todoItemBodyStack)
		
		NSLayoutConstraint.activate([
			selectionImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			selectionImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			selectionImage.widthAnchor.constraint(equalToConstant: 30),
			selectionImage.heightAnchor.constraint(equalToConstant: 30),
			
			todoItemBodyStack.leadingAnchor.constraint(equalTo: selectionImage.trailingAnchor, constant: 20),
			todoItemBodyStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			infoButton.leadingAnchor.constraint(equalTo: itemTitleLabel.trailingAnchor, constant: 10),
			infoButton.widthAnchor.constraint(equalToConstant: 30),
			infoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var editHandler: (TodoTableViewCell) -> Void = { _ in}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.selectionStyle = .none
	}
	
	func setupCell(with item: TodoItem, editHandler: @escaping (TodoTableViewCell) -> Void) {
		self.item = item
		self.itemTitleLabel.text = item.name
		self.itemTitleLabel.textColor = item.isDone ? .gray : .label
		self.itemTitleLabel.layer.opacity = item.isDone ? 0.5 : 1
		self.selectionImage.image = UIImage(systemName: item.isDone ? "checkmark.circle.fill" : "circle.dashed")
		self.selectionImage.layer.opacity = item.isDone ? 0.5 : 1
		self.editHandler = editHandler
		
		if let date = item.dateToRemind {
			remindDateLabel.attributedText = date.getStringFromDate()
		}
		remindDateLabel.isHidden = item.dateToRemind == nil ? true : false
	}
	
	lazy private var selectionImage: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = K.CustomColors.iconColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	lazy private var todoItemBodyStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [itemTitleLabel, remindDateLabel])
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 5
		stack.alignment = .leading
		stack.isLayoutMarginsRelativeArrangement = true
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	lazy private var itemTitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 20)
		label.numberOfLines = 2
		return label
	}()
	
	lazy private var remindDateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.numberOfLines = 1
		return label
	}()
	
	lazy private var infoButton: UIButton = {
		let infoButton = UIButton(type: .system)
		infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
		infoButton.tintColor = K.CustomColors.iconColor
		infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		return infoButton
	}()
	
	@objc private func infoButtonPressed() {
		editHandler(self)
	}
}
