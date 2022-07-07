//
//  TableViewCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import UIKit

class TableViewCell: UITableViewCell {
	
	var item = Item()
	
	
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
			infoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var editHandler: (TableViewCell) -> Void = { _ in}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		self.selectionStyle = .none
		
//		if editing == true {
//			UIImageView.animate(withDuration: 0.2) {
//				self.selectionImage.transform = CGAffineTransform(translationX: 0, y: 0)
//				self.label.transform = CGAffineTransform(translationX: 0, y: 0)
//				self.infoButton.isHidden = true
//			}
//		} else {
//			UIImageView.animate(withDuration: 0.2) {
//				self.selectionImage.transform = CGAffineTransform(translationX: -100, y: 0)
//				self.label.transform = CGAffineTransform(translationX: -50, y: 0)
//				self.infoButton.isHidden = false
//			}
//		}
	}
	
	func setupCell(with item: Item, editHandler: @escaping (TableViewCell) -> Void) {
		self.item = item
		self.label.text = item.title
		self.label.textColor = item.isDone ? .gray : .black
		self.selectionImage.image = UIImage(systemName: item.isDone ? "circle.fill" : "circle.dashed")
		self.editHandler = editHandler
	}
	
	lazy private var selectionImage: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	lazy private var label: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 20)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy private var infoButton: UIButton = {
		let infoButton = UIButton(type: .system)
		infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
		infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		return infoButton
	}()
//
	@objc private func infoButtonPressed() {
		editHandler(self)
	}
}
