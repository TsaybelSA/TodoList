//
//  Notifications.swift
//  TodoList
//
//  Created by Сергей Цайбель on 20.07.2022.
//

import UserNotifications
import UIKit
import RealmSwift

class Notifications: NSObject {
	
	let notificationCenter = UNUserNotificationCenter.current()
	var realm: Realm?
	
	func notificationRequest() {
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if let error = error {
				print("Some error occured \(error).")
			} else {
				print("User gave a permission.")
			}
		}
	}
	//TODO: if user change notifications settings need to let him know that it won`t be delivered
	
	func unscheduleNotification(with identifier: String) {
		notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
	}
	
	func addNewNotification(for item: TodoItem, with date: Date) -> String {
		let content = UNMutableNotificationContent()
		let userActions = "User Actions"
		
		// create notification content
		content.title = "Don`t forget:"
		content.subtitle = item.name
		content.body = "From category - \(item.parentCategory[0].name)"
		content.categoryIdentifier = userActions
		content.sound = .default
		
		//не знаю как увеличивать значение badge, когда приходит еще одно уведомление
		content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
		
		//create date trigger
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		//use item`s identifier or create new
		let identifier = item.notificationIdentifier ?? UUID().uuidString
		
		//make request
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		//add request to notificatin center
		notificationCenter.add(request) { error in
			if let error = error { print("Error - notification center, adding request \(error)") }
		}
		
		let remindAfterHour = UNNotificationAction(identifier: ActionIdentifiers.remindAfterHour.rawValue, title: "Remind after 1 hour", options: [])
		let remindTomorrow = UNNotificationAction(identifier: ActionIdentifiers.remindTomorrow.rawValue, title: "Remind tomorrow", options: [])
		let finished = UNNotificationAction(identifier: ActionIdentifiers.finished.rawValue, title: "Finished")
		let deleteTodoItem = UNNotificationAction(identifier: ActionIdentifiers.delete.rawValue, title: "Delete task", options: [.destructive])
		let category = UNNotificationCategory(identifier: userActions, actions: [remindAfterHour, remindTomorrow, finished, deleteTodoItem], intentIdentifiers: [])
		notificationCenter.setNotificationCategories([category])
		
		return identifier
	}
	
	enum ActionIdentifiers: String, CaseIterable {
		case remindAfterHour, remindTomorrow, finished, delete
	}
	
	func reschedule(by time: TimeInterval, _ item: TodoItem) {
		do {
			try realm?.write {
				if var date = item.dateToRemind {
					date += time
					item.dateToRemind! = date
					item.notificationIdentifier = addNewNotification(for: item, with: date)
					print(item)
				}
			}
		} catch {
			print("Failed to write to Realm \(error)")
		}
	}
	
	init(realm: Realm? = nil) {
		self.realm = realm
	}
}
//TODO: лучше перенести все операции с уведомлениями
//(включая writing to realm) в этот класс

extension Notifications: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .sound])
	}
	
	//will call when user interact with notification
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		do {
			let notificationID = response.notification.request.identifier
			guard let item = realm?.objects(TodoItem.self).first(where: { $0.notificationIdentifier == notificationID }) else { return }
			notificationCenter.removeDeliveredNotifications(withIdentifiers: [notificationID])
			
			switch response.actionIdentifier {
				case UNNotificationDismissActionIdentifier:
					print("Dismiss action")
				case UNNotificationDefaultActionIdentifier:
					//TODO: Fix - need to open current todoitem page
					let window = UIWindow()
					let rootViewController = WelcomeViewController()
					let navigationController = UINavigationController(rootViewController: rootViewController)
					navigationController.navigationBar.tintColor = K.CustomColors.iconColor
					window.rootViewController = navigationController
					print("Default")
					
				case ActionIdentifiers.remindAfterHour.rawValue:
					reschedule(by: 3600, item)
					print("remindAfterHour")
					
				case ActionIdentifiers.remindTomorrow.rawValue :
					reschedule(by: 3600*24, item)
					print("remindTomorrow")
					
				case ActionIdentifiers.finished.rawValue :
					try realm?.write {
						item.isDone = true
						item.notificationIdentifier = nil
						item.dateToRemind = nil
					}
					print("Finished")
					
				case ActionIdentifiers.delete.rawValue:
					try realm?.write {
						realm?.delete(item)
					}
					print("delete")
					
				default:
					print("Default action.")
			}
		} catch {
			print("Failer to write to Realm database \(error)")
		}
		completionHandler()
	}
}
