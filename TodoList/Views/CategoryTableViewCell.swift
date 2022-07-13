//
//  CategoryTableViewCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 07.07.2022.
//

import UIKit
import RealmSwift


class CategoryTableViewCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(themeImage)
		contentView.addSubview(infoButton)
		contentView.addSubview(titleLabel)
		NSLayoutConstraint.activate([
			themeImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			themeImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			//MARK: - change from 0 value when apply images
			themeImage.widthAnchor.constraint(equalToConstant: 0),
			themeImage.heightAnchor.constraint(equalToConstant: 0),
			titleLabel.leadingAnchor.constraint(equalTo: themeImage.trailingAnchor, constant: 20),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
			infoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	func setupCell(with title: String) {
		titleLabel.text = title
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	lazy private var themeImage: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	lazy private var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 24)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
		self.selectionStyle = .none
    }
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		if isEditing == true {
			accessoryType = .none
			infoButton.isHidden = false
			UIButton.animate(withDuration: 0.2) {
				self.infoButton.layer.opacity = 1
			}
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				self.infoButton.isHidden = true
				self.accessoryType = .disclosureIndicator
			}
			UIButton.animate(withDuration: 0.2) {
				self.infoButton.layer.opacity = 0
			}
		}
	}
	
	@objc func infoButtonPressed() {
		
	}

}
