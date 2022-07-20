//
//  Notifications.swift
//  TodoList
//
//  Created by Сергей Цайбель on 20.07.2022.
//

import Foundation
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
	
	let notificationCenter = UNUserNotificationCenter.current()
	
//	notificationCenter.getNotificationSettings { (settings) in
	//		  if settings.authorizationStatus != .authorized {
	//			// Notifications not allowed
	//			  //Need to write alert here
	//			  //User should change settings to let app send notifications
	//		  }
	//		}
	
	func notificationRequest() {
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if let error = error {
				print("Some error occured \(error).")
			} else {
				print("User gave a permission.")
			}
		}
	}
	
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
		content.badge = 1
		
		//create date trigger
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		//use item identifier or create new
		let identifier = item.notificationIdentifier ?? UUID().uuidString
		
		//make request
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		//add request to notificatin center
		notificationCenter.add(request) { error in
			if let error = error { print("Error - notification center, adding request \(error)") }
		}
		
		let remindAfterHour = UNNotificationAction(identifier: "remindAfterHour", title: "Remind after 1 hour", options: [])
		let remindTomorrow = UNNotificationAction(identifier: "remindTomorrow", title: "Remind tomorrow", options: [])
		//можно добавить - удалить напоминание; isDone = true (выполнено)
		let category = UNNotificationCategory(identifier: userActions, actions: [remindAfterHour, remindTomorrow], intentIdentifiers: [])
		notificationCenter.setNotificationCategories([category])
		
		return identifier
	}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .sound])
	}
	
	//will call when user interact with notification
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
			case UNNotificationDismissActionIdentifier:
				print("Dismiss action")
			case UNNotificationDefaultActionIdentifier:
				// can try to find category of item
				// using notificationIdentifier and open it
				print("Default")
			case "remindAfterHour":
				print("remindAfterHour")
			case "remindTomorrow" :
				print("remindTomorrow")
			default:
				print("Default action.")
		}
	}
}
