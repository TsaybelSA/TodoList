//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 07.07.2022.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {
	
	let realm: Realm
	let realmConfiguration: Realm.Configuration
	var notificationToken: NotificationToken?
	
	var categories: Results<Category>
		
	required init(realmConfiguration: Realm.Configuration) {
		self.realm = try! Realm(configuration: realmConfiguration)
		self.realmConfiguration = realmConfiguration
		   
		categories = realm.objects(Category.self).sorted(byKeyPath: "index")

		super.init(nibName: nil, bundle: nil)
		
		notificationToken = categories.observe { [weak self] (changes) in
			guard let tableView = self?.tableView else { return }
			switch changes {
			case .initial:
				tableView.reloadData()
			case .update(_, let deletions, let insertions, let modifications):
				tableView.performBatchUpdates({
					tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
				})
			case .error(let error):
				fatalError("\(error)")
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		notificationToken?.invalidate()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		print(Realm.Configuration.defaultConfiguration.fileURL)
		
		setupView()
    }
	
	private let tableView: UITableView = {
		$0.translatesAutoresizingMaskIntoConstraints = false
	return $0 }(UITableView())
	
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		view.backgroundColor = .white
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationController?.navigationBar.prefersLargeTitles = true
		title = "What Todo"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		navigationItem.leftBarButtonItem = editButtonItem
		
//		private var barLabel = UIBarButtonItem()
//		toolbarItems = [barLabel]
//		navigationController?.setToolbarHidden(false, animated: false)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
		tableView.rowHeight = 50
		tableView.allowsSelectionDuringEditing = true
		
		setupToHideKeyboardOnTapOnView()
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}

	//MARK: - Creating New Category
	
	@objc private func addButtonPressed() {
		let ac = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
		ac.addTextField { textField in
			textField.placeholder = "Write title"
		}
		let confirmAction = UIAlertAction(title: "Add Category", style: .default) { _ in
			guard let text = ac.textFields!.first?.text else { return }
			guard text != " " && text != "" else { return }

			do {
				try self.realm.write {
					let newCategory = Category()
					newCategory.name = text
					newCategory.index = min(0, self.categories.count)
					self.realm.add(newCategory)
				}
			} catch {
				print("Failed to save data: \(error)")
			}
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
	
}

//MARK: - Table View Methods

extension CategoryViewController: UITableViewDelegate {
	
	//MARK: - Push todoItemsViewController
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = TodoItemsViewController(realmConfiguration: realmConfiguration, selectedCategory: categories[indexPath.row])
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//Move rows
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		do {
			try self.realm.write {
				categories.moveObject(from: sourceIndexPath.row, to: destinationIndexPath.row)
			}
		} catch {
			print("Error writing data to Realm database \(error)")
		}

	}
	
	//swipe to delete
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
			do {
				try self.realm.write {
					self.realm.delete(self.categories[indexPath.row])
				}
			} catch {
				print("Error writing data to Realm database \(error)")
			}
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

extension CategoryViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
		cell.setupCell(with: categories[indexPath.row].name)
		return cell
	}
}
