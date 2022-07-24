//
//  EditCategoryVC.swift
//  TodoList
//
//  Created by Сергей Цайбель on 15.07.2022.
//

import UIKit
import RealmSwift

class EditCategoryVC: UIViewController {

	let realm = (UIApplication.shared.delegate as! AppDelegate).realm!
	var category: Category
	
	private let thumbnailSize = CGSize(width: 40, height: 40)
	private let sectionInsets = UIEdgeInsets(top: 10, left: 5.0, bottom: 10.0, right: 5.0)
	
	private let imageArray = ["star.slash", "star", "exclamationmark.circle", "gamecontroller", "tv", "car", "bus", "tram", "bicycle", "scooter", "tshirt","heart", "bolt.heart", "giftcard", "dollarsign.square","brain.head.profile", "pills", "pawprint", "leaf"]
		
	required init(cellItem: Category) {
		self.category = cellItem
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .secondarySystemBackground
		
		setupToHideKeyboardOnTapOnView()
		textField.delegate = self
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
		
		view.addSubview(dissmissViewButton)
		view.addSubview(changeTitleLabel)
		view.addSubview(textField)
		view.addSubview(chooseImageLabel)
		view.addSubview(collectionView)
		
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
			
			chooseImageLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 10),
			chooseImageLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
			chooseImageLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
			chooseImageLabel.heightAnchor.constraint(equalToConstant: 30),
			
			collectionView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: chooseImageLabel.bottomAnchor, constant: 5),
			collectionView.heightAnchor.constraint(equalToConstant: countCollectionViewHeight())
		])
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
	}
	
	private var changeTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Rename category:"
		label.font = UIFont.systemFont(ofSize: 18)
		label.textColor = .darkGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var collectionView: UICollectionView = {
		let collectionViewLayout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .secondarySystemBackground
		return collectionView
	}()
	
	private var chooseImageLabel: UILabel = {
		let label = UILabel()
		label.text = "Choose icon for category:"
		label.font = UIFont.systemFont(ofSize: 18)
		label.textColor = .darkGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var textField: UITextField = {
		let textField = UITextField()
		textField.text = category.name
		textField.backgroundColor = .systemBackground
		textField.font = UIFont.systemFont(ofSize: 22)
		textField.textColor = .label
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.makeBorderedWithShadow()
		textField.setLeftPaddingPoints(10)
		return textField
	}()
	
	private lazy var dissmissViewButton: UIButton = {
		let buttonImage = UIImage(systemName: "x.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
		$0.setImage(buttonImage, for: .normal)
		$0.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
		$0.translatesAutoresizingMaskIntoConstraints = false
	return $0 } (UIButton(type: .system))
	
	@objc func dismissView() {
		dismiss(animated: true)
	}
}

extension EditCategoryVC: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		do {
			try realm.write {
				category.name = text
			}
		} catch {
			print("Error deleting item from Realm database \(error)")
		}
		print("End edit")
	}
}

// MARK:- UICollectionViewDataSource
extension EditCategoryVC: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageArray.count
  }
  
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
		let image = UIImage(systemName: imageArray[indexPath.row])!
		cell.setup(with: image)
		
		//MARK: - if icon wasn`t chosen -- FIX
		if category.icon == nil && imageArray[indexPath.row] == "star.slash" {
			cell.isSelected = true
		}
		
	  return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let chosenIcon = imageArray[indexPath.row]
		do {
			try realm.write {
				category.icon = chosenIcon == "star.slash" ? nil : chosenIcon
			}
		} catch {
			print("Error writing to Realm database \(error)")
		}
	}
}

// MARK:- UICollectionViewDelegateFlowLayout
extension EditCategoryVC : UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return thumbnailSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	private func countCollectionViewHeight() -> CGFloat {
		return collectionView.collectionViewLayout.collectionViewContentSize.height
	}
}

extension EditCategoryVC: UICollectionViewDelegate {
	
}
