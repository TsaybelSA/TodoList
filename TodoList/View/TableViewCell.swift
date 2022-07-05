//
//  TableViewCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import UIKit

class TableViewCell: UITableViewCell {
	
	var todoItem: TodoItem!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubview(infoButton)
		contentView.addSubview(label)
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			infoButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
			infoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var editHandler: (TableViewCell, IndexPath) -> Void = { _, _ in}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		self.selectionStyle = .none
    }
	
	func setupCell(with item: TodoItem, editHandler: @escaping (TableViewCell, IndexPath) -> Void) {
		self.todoItem = item
		self.label.text = item.text
		self.editHandler = editHandler
	}
	
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
//		guard let self = self else { return }
		editHandler(self, IndexPath())
	}
}
