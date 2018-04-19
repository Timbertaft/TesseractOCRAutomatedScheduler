//
//  ViewController.swift
//  TesseractOCRAutomatedScheduler
//
//  Created by Mike Posse on 4/15/18.
//  Copyright © 2018 Mike Posse. All rights reserved.
//

import UIKit
import TesseractOCR
import GoogleSignIn
import GoogleAPIClientForREST
import CoreFoundation



class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    var tesstext = [String]()
    
    //Values for reference and mutation in creating events Below.
    var manualloop = 0
    var monthnumber = 0
    let month = [1 : "January", 2 : "February", 3: "March", 4: "April", 5: "May", 6: "June", 7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"]
    var describer = ""
    //Values for reference and mutation in creating events Above.
    
    
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        //GIDSignIn.sharedInstance().signInSilently()
        signInButton.frame = CGRect(x:0, y: 0, width: 200, height: 300)
        signInButton.center = view.center
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output. TODO: THIS IS A PLACEHOLDER
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        view.addSubview(output);
    }
    
    @objc func handleLogout() {
        self.signInButton.isHidden = false
        self.output.isHidden = true
        GIDSignIn.sharedInstance().signOut()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            presentImagePicker()
            
            //fetchEvents()
            //GTLRCalendarQuery_EventsInsert
        }
        
        
    }
    
    
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func GenerateEvent()
    {
        // TODO: Temporary: remember to move these variable setters out of the function.  Otherwise manual loop will reset to 0 everytime.
       
        var time = matches(for: "\\d{1,2}:\\d\\d \\w{1,2} - \\d{1,2}:\\d\\d\\s\\w{0,2}", in: tesstext[manualloop])
        var daymatch = matches(for: "\\s\\d{1,2}\\s", in: tesstext[manualloop])
        var fulltime = [String]()
        var starttime = ""
        var endtime = ""
        var finaldayvalue = ""
        var nameofmonth = ""
        
        if(time[0] != "")
        {
        fulltime = time[0].components(separatedBy: " - ")
        //TODO: start and end times present, but need to be trimmed of extras and have condition inserted to increase value by 12 if pm or am.
        starttime = fulltime[0]
        endtime = fulltime[1]
            describer = time[0]
        }
        //Below account for common character matching issues
        
        //TODO: Create character error catching
        
        //Below expression matches array value for day and generates variable in 2 digit numerical format.
        
        if(daymatch[0] != "") {
        daymatch[0] = daymatch[0].trimmingCharacters(in: .whitespacesAndNewlines)
        finaldayvalue = String(format: "%02d", daymatch[0])
        }
        // Above expression for day values.
        
        //Below expression for month values
        for(monthdigit, monthname) in month {
            
            if(tesstext[manualloop] == monthname)
            {
                monthnumber = monthdigit
                nameofmonth = monthname
            }
        }

        if(monthnumber != 0 && String(finaldayvalue) != "" && describer != "") {
            //Above expression for month values.
            let RFC3339DateFormatter = DateFormatter()
            let RFC3339DateFormatternotime = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            RFC3339DateFormatternotime.dateFormat = "yyyy-MM-dd"
            // Above formats values into parsable dates.
            //Below variables for time and dates parsable by calendar.
            var date = "2018-" + String(monthnumber) + "-" + String(finaldayvalue)
            var datetimestart = (date + "T" + starttime)
            var dattimeend = (date + "T" + endtime)
            var datefinalstart = RFC3339DateFormatter.date(from: datetimestart)
            var datefinal = RFC3339DateFormatternotime.date(from: date)
            var datefinalend = RFC3339DateFormatter.date(from: dattimeend)
            //TODO: Learn what offset minutes represents
            var googledatestart = GTLRDateTime(date: datefinalstart!, offsetMinutes: 5)
            var googledatenotime = GTLRDateTime(date: datefinal!)
            var googledateend = GTLRDateTime(date: datefinalend!, offsetMinutes: 50)
            //var offsetMinutes = [TimeZone .localizedName(EST)]
            var newevent = GTLRCalendar_Event()
            newevent.summary = describer
            newevent.descriptionProperty = describer
            var reminder = GTLRCalendar_EventReminder()
            reminder.minutes = 60
            reminder.method = "SMS"
            newevent.reminders = GTLRCalendar_Event_Reminders()
            newevent.reminders?.overrides = [reminder]
            newevent.reminders?.useDefault = false
            //Compounds above information into a new event below.
            
            //Below checks if there are time values, otherwise all day event.
            if(datefinalstart != nil && datefinalend != nil) {
            
            newevent.start = GTLRCalendar_EventDateTime()
            newevent.start?.dateTime = googledatestart
            newevent.end = GTLRCalendar_EventDateTime()
            newevent.end?.dateTime = googledateend
            addEvent(newevent)
            }
            else {
                newevent.start = GTLRCalendar_EventDateTime()
                newevent.start?.dateTime = googledatenotime
                addEvent(newevent)
                
            }
            
            //TODO: Create logic for identifying description.
            
        }
        
        if((monthnumber == 0 || String(finaldayvalue) == "" || describer == "") && tesstext[manualloop] != "" && (tesstext[manualloop] != nameofmonth || tesstext[manualloop] != describer || tesstext[manualloop] != String(finaldayvalue))) {
            //TODO: create user alert with text entry modifiers.
        }
        else
        {
            manualloop += 1
            GenerateEvent()
        }
        
    }
    //Below executes query to API to attempt event insertion.
    func addEvent(_ event: GTLRCalendar_Event) {
        let service = GTLRCalendarService()
        let selectedCalendar = GTLRCalendar_CalendarListEntry()
        let calendarID = selectedCalendar.identifier
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        query.fields = "id"
        self.service.executeQuery(
            query,
            completionHandler: {(_ callbackTicket:GTLRServiceTicket,
                _  event:GTLRCalendar_Event,
                _ callbackError: Error?) -> Void in}
                as? GTLRServiceCompletionHandler
        )
        manualloop += 1
        GenerateEvent()
    }
    
    
    // Construct a query and get a list of upcoming events from the user calendar
    /*func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Display the start dates and event summaries in the UITextView
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        if let events = response.items, !events.isEmpty {
            for event in events {
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = DateFormatter.localizedString(
                    from: start.date,
                    dateStyle: .short,
                    timeStyle: .short)
                outputText += "\(startString) - \(event.summary!)\n"
            }
        } else {
            outputText = "No upcoming events found."
        }
        output.text = outputText
    }
    
    
    // Helper for showing an alert
    */func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func performImageRecognition(_ image: UIImage) {
        
        if let tesseract = G8Tesseract(language: "eng") {
            print(tesstext)
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .singleColumn
            tesseract.image = image.g8_blackAndWhite()
            var x = [12, 485, 1057, 1646, 2223, 2806, 3404, 12, 501, 1069, 1635, 2211, 2793, 3385, 21, 525, 1076, 1641, 2210, 2780, 3364, 17, 533, 1085, 1644, 2202, 2765, 3345, 12, 540, 1093, 1645, 2199, 2761, 3323]
            var y = [326, 341, 358, 369, 390, 388, 390, 820, 843, 856, 853, 875, 891, 897, 1289, 1304, 1313, 1333, 1348, 1367, 1380, 1744, 1759, 1778, 1791, 1813, 1831, 1861, 2186, 2211, 2232, 2244, 2262, 2282, 2306]
            var height = [445, 460, 458, 468, 451, 460, 487, 434, 428, 427, 459, 424, 412, 447, 435, 433, 426, 442, 435, 448, 429, 410, 405, 415, 417, 412, 417, 422, 434, 414, 408, 425, 421, 429, 422]
            var width = [434, 549, 555, 549, 558, 565, 582, 455, 543, 542, 548, 550, 562, 581, 478, 526, 537, 535, 541, 549, 567, 487, 523, 534, 528, 537, 546, 559, 513, 527, 529, 517, 524, 535, 557]
            
            for (index, value) in x.enumerated() {
                
            tesseract.rect = CGRect(x: x[index], y: y[index], width: width[index], height: height[index])
            tesseract.recognize()
            tesstext[index] = tesseract.recognizedText
            }
            

        }
        print(tesstext)
        //activityIndicator.stopAnimating()
    }
    
    
}

// 1
// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 1
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 2
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        // 3
        present(imagePickerActionSheet, animated: true)
    }
    // 1
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // 2
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage() {
            // 3
            //activityIndicator.startAnimating()
            // 4
            
            
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage() -> UIImage? {
        
        var scaledSize = CGSize(width: 4048, height: 3036)
        
        if(size.height > size.width)
        {
            //TODO: Create alert to catch images not in landscape mode.
           
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
}
