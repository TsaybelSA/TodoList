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
		imageView.contentMode = .scaleToFill
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
		contentView.layer.cornerRadius = Constants.contentViewCornerRadius

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
	
	private enum Constants {
		// MARK: contentView layout constants
		static let contentViewCornerRadius: CGFloat = 4.0

		// MARK: Generic layout constants
		static let verticalSpacing: CGFloat = 8.0
		static let horizontalPadding: CGFloat = 16.0
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup(with image: UIImage) {
		imageView.image = image.withTintColor(.green)
		
	}
}

extension ImageCell: ReusableCell {
	static var identifier: String {
		return String(describing: self)
	}
}
