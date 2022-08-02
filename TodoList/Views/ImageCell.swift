//
//  ImageCell.swift
//  TodoList
//
//  Created by Сергей Цайбель on 15.07.2022.
//

import UIKit

protocol ReusableCell: AnyObject {
	static var identifier: String { get }
}

class ImageCell: UICollectionViewCell {
	
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = K.CustomColors.iconColor
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		setupViews()
		setupLayout()
	}
	
	private func setupViews() {
		contentView.clipsToBounds = true
		self.layer.cornerRadius = Constants.contentViewCornerRadius

		contentView.addSubview(imageView)
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	override var isSelected: Bool {
		didSet{
			if self.isSelected {
				UIView.animate(withDuration: Constants.duration) { // for animation effect
					self.backgroundColor = K.CustomColors.iconColor
					self.imageView.tintColor = .systemBackground
				}
			}
			else {
				UIView.animate(withDuration: Constants.duration) { // for animation effect
					self.backgroundColor = .clear
					self.imageView.tintColor = K.CustomColors.iconColor
				}
			}
		}
	}
	
	private enum Constants {
		// MARK: contentView layout constants
		static let contentViewCornerRadius: CGFloat = 8.0

		// MARK: Animation duration
		static let duration: Double = 0.3
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup(with image: UIImage) {
		imageView.image = image
	}
}

extension ImageCell: ReusableCell {
	static var identifier: String {
		return String(describing: self)
	}
}
