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
		contentView.addSubview(label)
		NSLayoutConstraint.activate([
			selectionImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			selectionImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			selectionImage.widthAnchor.constraint(equalToConstant: 30),
			selectionImage.heightAnchor.constraint(equalToConstant: 30),
			label.leadingAnchor.constraint(equalTo: selectionImage.trailingAnchor, constant: 20),
			label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			infoButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
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
		self.label.text = item.name
		self.label.textColor = item.isDone ? .gray : .label
		self.label.layer.opacity = item.isDone ? 0.5 : 1
		self.selectionImage.image = UIImage(systemName: item.isDone ? "checkmark.circle.fill" : "circle.dashed")
		self.selectionImage.layer.opacity = item.isDone ? 0.5 : 1
		self.editHandler = editHandler
	}
	
	lazy private var selectionImage: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = K.CustomColors.iconColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	lazy private var label: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 20)
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
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
