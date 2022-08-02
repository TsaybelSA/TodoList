//
//  CategoryTableViewCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 07.07.2022.
//

import UIKit
import RealmSwift


class CategoryTableViewCell: UITableViewCell {
	
	var editHandler: (CategoryTableViewCell) -> Void = { _ in}
	var category = Category()
	
	var imageWidthAnchor: NSLayoutConstraint?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(themeImageView)
		contentView.addSubview(infoButton)
		contentView.addSubview(titleLabel)
		
		imageWidthAnchor = themeImageView.widthAnchor.constraint(equalToConstant: 0)
		imageWidthAnchor?.isActive = true
		
		NSLayoutConstraint.activate([
			themeImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			themeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			themeImageView.heightAnchor.constraint(equalToConstant: 40),
			
			//MARK: - widthAnchor and heightAnchor change from 0 value when apply image
			titleLabel.leadingAnchor.constraint(equalTo: themeImageView.trailingAnchor, constant: 20),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: 10),
			
			infoButton.widthAnchor.constraint(equalToConstant: 30),
			infoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	func setupCell(with category: Category, editHandler: @escaping (CategoryTableViewCell) -> Void) {
		titleLabel.text = category.name
		self.category = category
		self.editHandler = editHandler

		if category.icon == nil {
			imageWidthAnchor?.isActive = false
			imageWidthAnchor = themeImageView.widthAnchor.constraint(equalToConstant: 0)
			imageWidthAnchor?.isActive = true
		} else {
			themeImageView.image = UIImage(systemName: category.icon!)
			themeImageView.tintColor = K.CustomColors.iconColor
			
			imageWidthAnchor?.isActive = false
			imageWidthAnchor = themeImageView.widthAnchor.constraint(equalToConstant: 40)
			imageWidthAnchor?.isActive = true
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	lazy private var themeImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	lazy private var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 22)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy private var infoButton: UIButton = {
		let infoButton = UIButton(type: .system)
		infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
		infoButton.contentMode = .scaleAspectFill
		infoButton.tintColor = K.CustomColors.iconColor
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
			UIButton.animate(withDuration: Constants.Animation.duration) {
				self.infoButton.layer.opacity = 1
			}
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.timeToWait) {
				self.infoButton.isHidden = true
				self.accessoryType = .disclosureIndicator
			}
			UIButton.animate(withDuration: Constants.Animation.duration) {
				self.infoButton.layer.opacity = 0
			}
		}
	}
	
	private enum Constants {
		// MARK: contentView layout constants
		static let contentViewCornerRadius: CGFloat = 8.0
		
		// MARK: Animation constants
		struct Animation {
			static let timeToWait: Double = 0.3
			static let duration: Double = 0.2
		}
	}
	
	@objc func infoButtonPressed() {
		editHandler(self)
	}

}
