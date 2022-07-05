//
//  ViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import SwiftUI

class RootViewController: UIViewController {
	
	var items = [TodoItem(text: "First but not least"), TodoItem(text: "one more"), TodoItem(text: "just do it"), TodoItem(text: "good job!")]
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Todo List"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		setupView()
	}
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(TableViewCell.self, forCellReuseIdentifier: "reusableCell")
		tableView.rowHeight = 50
//		tableView.separatorStyle = .none
		
		
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	@objc private func addButtonPressed() {
		let ac = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
		ac.addTextField { textField in
			textField.placeholder = "Write task"
		}
		let confirmAction = UIAlertAction(title: "Add Item", style: .default) { _ in
			guard let text = ac.textFields!.first?.text else { return }
			let newItem = TodoItem(text: text)
			guard newItem.text != "" else { return }
			self.items.append(newItem)
			self.tableView.reloadData()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
}

//MARK: - UITableViewDelegate

extension RootViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
			tableView.cellForRow(at: indexPath)?.accessoryType = .none
		} else {
			tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		}
	}
	
	//MARK: - Edit Cell

	private func editCell(_ cell: TableViewCell, at indexPath: IndexPath) -> Void {
		let vc = EditCellViewController()
		vc.todoItem = cell.todoItem
		vc.complition = { [weak self] todoItem in
			if let itemIndex = self?.items.firstIndex(where: { $0.id == todoItem.id }) {
				self?.items[itemIndex].text = todoItem.text
				print("text from complition: \(todoItem.text)")
				self?.tableView.reloadData()
			}

		}
		present(vc, animated: true)
	}
}

//MARK: - UITableViewDataSource

extension RootViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath) as! TableViewCell
		cell.setupCell(with: items[indexPath.row], editHandler: editCell)
		return cell
	}
}



struct SwiftUIController: UIViewControllerRepresentable {
	typealias UIViewControllerType = RootViewController
	
	func makeUIViewController(context: Context) -> UIViewControllerType {
		let vc = UIViewControllerType()
		return vc
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
	}
}

struct SwiftUIController_Previews: PreviewProvider {
	static var previews: some View {
		SwiftUIController().edgesIgnoringSafeArea(.all)
	}
}

