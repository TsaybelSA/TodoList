//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 07.07.2022.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var categories = [Category]()
	
	var todoItems = [Item]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .white
		title = "What Todo"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

		loadCategories()
		setupView()
    }
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
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
			let newCategory = Category(context: self.context)
			newCategory.name = text
			let safeIndex = Float(min(0, self.categories.count))
			newCategory.id = Int64(safeIndex)
			self.categories.append(newCategory)
			self.saveCategories()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	//MARK: - Model Manipulation Methods
	
	private func saveCategories() {
		do {
			try context.save()
			print("Saved")
		} catch {
			print("Failed to save context: \(error)")
		}
		tableView.reloadData()
	}
	
	private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
		do {
			request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
			categories = try context.fetch(request)
		} catch {
			print("Failed to fetch data from context! \(error)")
		}
		tableView.reloadData()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
	
}

//MARK: - Table View Methods

extension CategoryViewController: UITableViewDelegate {
	
	// prepare and push todoItemsViewController
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = TodoItemsViewController(categories[indexPath.row])
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//Moving rows
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let category = categories[sourceIndexPath.row]
		categories.remove(at: sourceIndexPath.row)
		categories.insert(category, at: destinationIndexPath.row)
		for (index, item) in categories.enumerated() {
			item.id = Int64(Float(index))
		}
		saveCategories()
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
			self.context.delete(self.categories[indexPath.row])
			self.categories.remove(at: indexPath.row)
			self.saveCategories()
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
		cell.setupCell(with: categories[indexPath.row].name ?? "noName")
		return cell
	}
}
