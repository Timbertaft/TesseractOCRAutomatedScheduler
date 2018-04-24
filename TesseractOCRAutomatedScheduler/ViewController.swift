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
import Foundation



class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    private let Service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    var tesstext = [String]()
    
    //Values for reference and mutation in creating events Below.
    var manualloop = 0
    var monthnumber = 0
    let month = [1 : "January", 2 : "February", 3: "March", 4: "April", 5: "May", 6: "June", 7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"]
    var nameofmonth = ""
    var describer = ""
    var finaldayvalue = ""
    var starttime = ""
    var endtime = ""
    var iterationvalue = 0
    var time = [String]()
    var timecontained = 0
    var oddday = 0
    var eventgenerationchecker = 0
    var tesstextcheck = ""
    var dayiterate = 0
    var daymemory = 0
    
    //Values for reference and var daymemory = daymatch in creating events Above.
    
    
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
            self.Service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.Service.authorizer = user.authentication.fetcherAuthorizer()
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
        //print(tesstext)
        tesstextcheck = tesstext[manualloop]
        
        //if(tesstextcheck.isEmpty == false) {
        // TODO: Temporary: remember to move these variable setters out of the function.  Otherwise manual loop will reset to 0 everytime.
        if(timecontained != 1){
            //print(tesstext[manualloop])
        time = matches(for: "\\d{1,2}:\\d\\d \\w{1,2} - \\d{1,2}:\\d\\d\\s\\w{0,2}", in: tesstext[manualloop])
            //print (tesstext[manualloop])
            //print(time)
        } else {
            print(time[0])
            
        }
        var daymatch = matches(for: "^\\d{1,2}\\n", in: tesstext[manualloop])
        var fulltime = [String]()
        
        for(monthdigit, monthname) in month {
            
            if(tesstext[manualloop].range(of: monthname) != nil)
            {
                monthnumber = monthdigit
                nameofmonth = monthname
                
            }
        }
        let range1 = tesstext[manualloop].range(of: nameofmonth)
        if(time.isEmpty == false)
        {
            if(timecontained == 1){
                print(time[0])
            }
            print(time[0] + " time isn't empty.")
            time[0] = time[0].trimmingCharacters(in: .whitespacesAndNewlines)
            describer = time[0]
            fulltime = time[0].components(separatedBy: ["-",":"," "])
            fulltime = fulltime.filter { $0 != ""}
        //TODO: start and end times present, but need to be trimmed of extras and have condition inserted to increase value by 12 if pm or am.
        print(fulltime)
            if(fulltime[2].contains("p") || fulltime[2].contains("P")){
                if(Int(fulltime[3])! > Int(fulltime[0])!) {
                    fulltime[3] = String(Int(fulltime[3])! + 12)
                }
                fulltime[0] = String(Int(fulltime[0])! + 12)
            }
            else if((fulltime[fulltime.count - 1].contains("p") || fulltime[fulltime.count - 1].contains("P")) && Int(fulltime[3])! < 12) {
                fulltime[3] = String(Int(fulltime[3])! + 12)
            }
            else if(!fulltime[2].contains("a") || !fulltime[2].contains("A")) {
                AlertGenerator()
            }
            if((fulltime[2].contains("A") || fulltime[2].contains("a")) && fulltime[0].contains("12")) {
                fulltime[0] = String(Int(fulltime[0])! - 12)
            }
            if((fulltime[fulltime.count - 1].contains("A") || fulltime[fulltime.count - 1].contains("a")) && fulltime[3].contains("12")) {
                fulltime[3] = String(Int(fulltime[3])! - 12)
            }
            starttime = String(format: "%02d", Int(fulltime[0])!) + ":" + String(format: "%02d", Int(fulltime[1])!)
            endtime = String(format: "%02d", Int(fulltime[3])!) + ":" + String(format: "%02d", Int(fulltime[4])!)
            //print(describer)
        }
            
        //Below account for common character matching issues
        
        //TODO: Create character error catching
        
        //Below expression matches array value for day and generates variable in 2 digit numerical format.
        
        if(!daymatch.isEmpty) {
            dayiterate += 1
        daymatch[0] = daymatch[0].trimmingCharacters(in: .whitespacesAndNewlines)
        print(daymatch[0] + " day isn't empty")
        finaldayvalue = String(format: "%02d", Int(daymatch[0])!)
            daymemory = Int(daymatch[0])!
            print(finaldayvalue)
        } else if(range1 != nil) {
            dayiterate += 1
            AlertGenerator()
        }
        else if(daymatch.isEmpty && !time.isEmpty) {
             oddday = 1
            if(daymemory != 0) {
            print(String(daymemory) + " daymemory is active")
                daymatch.insert(String(daymemory + (manualloop - dayiterate)), at: 0)
            finaldayvalue = String(format: "%02d", Int(daymatch[0])!)
            dayiterate += 1
            //print(finaldayvalue)
            }
        }
        // Above expression for day values.
        
        //Below expression for month values
        
        print(nameofmonth + " " + String(monthnumber) + " month isn't empty")
        //TODO: Create logic for identifying description.
            let range2 = tesstext[manualloop].range(of: describer)
            let range3 = tesstext[manualloop].range(of: String(finaldayvalue))
            tesstextcheck = tesstextcheck.replacingOccurrences(of: "^\\d{1,2}\\n", with: "", options: .regularExpression)
            tesstextcheck = tesstextcheck.trimmingCharacters(in: .whitespacesAndNewlines)
            print(tesstextcheck)
            if (range1 != nil) {
            print(nameofmonth + " yup")
            }
            else {
                print("month was nil")
            }
            if (range2 != nil) {
                print(describer + " yup")
            }
            else {
                print("describer was nil")
            }
            if (range3 != nil)
            {
            print(String(finaldayvalue + " yup"))
            }
            else {
                print("day was nil")
            }
        //if((monthnumber == 0 || finaldayvalue.isEmpty == true || time.isEmpty == true) && tesstext[manualloop].isEmpty == false && ((tesstext[manualloop].range(of: nameofmonth) == nil && tesstext[manualloop].range(of: describer) != nil && tesstext[manualloop].range(of: String(finaldayvalue)) != nil) || (tesstext[manualloop].range(of: describer) == nil && tesstext[manualloop].range(of: nameofmonth) != nil && tesstext[manualloop].range(of: String(finaldayvalue)) != nil) || (tesstext[manualloop].range(of: String(finaldayvalue)) == nil && tesstext[manualloop].range(of: describer) != nil && tesstext[manualloop].range(of: nameofmonth) != nil)) && oddday != 1)
        
        if((((monthnumber == 0 || finaldayvalue.isEmpty || time.isEmpty) && !tesstext[manualloop].isEmpty && (range1 == nil && ((range3 == nil || (range2 == nil && !tesstextcheck.isEmpty))) || (!finaldayvalue.isEmpty && Int(finaldayvalue)! > 31)) && oddday != 1)) || (range1 == nil && range2 == nil && range3 == nil) && oddday != 1) {
            AlertGenerator()
        }
        else if(monthnumber > 0 && !finaldayvalue.isEmpty && !starttime.isEmpty && !endtime.isEmpty) {
            CreateEvents()
            }
        else if(manualloop < 34){
            manualloop += 1
            GenerateEvent()
        }
            else {
                CompletionAlert()
        }
    }
    
    
    func NextIterate() {
        if(iterationvalue == 1 && self.manualloop < 34) {
        manualloop += 1
        starttime = ""
        endtime = ""
        finaldayvalue = ""
        describer = ""
        iterationvalue = 0
        timecontained = 0
        oddday = 0
        }
        else if(monthnumber != 0 && String(finaldayvalue) != "" && describer != "" && self.manualloop < 34) {
            CreateEvents()
            }
        else if(self.manualloop < 34) {
            manualloop += 1
            GenerateEvent()
            }
        else if(self.manualloop > 34 && eventgenerationchecker == 0) {
            FailureAlert()
        }
        else
        {
            CompletionAlert()
        }
        }
    

        func CreateEvents() {
            eventgenerationchecker += 1
            print(monthnumber)
            print(String(finaldayvalue))
            print(describer)
            
            let RFC3339DateFormatter = DateFormatter()
            let RFC3339DateFormatternotime = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            RFC3339DateFormatternotime.dateFormat = "yyyy-MM-dd"
            // Above formats values into parsable dates.
            //Below variables for time and dates parsable by calendar.
            let date = "2018-" + String(format: "%02d", monthnumber) + "-" + String(finaldayvalue)
            let datetimestart = (date + "T" + starttime)
            let dattimeend = (date + "T" + endtime)
            let datefinalstart = RFC3339DateFormatter.date(from: datetimestart)
            //print(RFC3339DateFormatter.string(from: datefinalstart!))
            let datefinal = RFC3339DateFormatternotime.date(from: date)
            //print(RFC3339DateFormatter.string(from: datefinal!))
            let datefinalend = RFC3339DateFormatter.date(from: dattimeend)
            //print(RFC3339DateFormatter.string(from: datefinalend!))
            //TODO: Learn what offset minutes represents
            let googledatestart = GTLRDateTime(date: datefinalstart!)
            let googledatenotime = GTLRDateTime(date: datefinal!)
            let googledateend = GTLRDateTime(date: datefinalend!)
            let newevent = GTLRCalendar_Event()
            newevent.summary = describer
            newevent.descriptionProperty = describer
            let reminder = GTLRCalendar_EventReminder()
            reminder.minutes = 60
            reminder.method = "email"
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
                newevent.start?.date = googledatenotime
                addEvent(newevent)
            }
        }
    
    func AlertGenerator() {
        //TODO : Add alerts to account for incorrect textual inputs.
        let alert = UIAlertController(title: "Is the below text meant to be a description of an event?", message: tesstext[manualloop], preferredStyle: .alert)
        let alert2 = UIAlertController(title: "Is it correct as is?", message: nil, preferredStyle: .alert)
        let alert3 = UIAlertController(title: "Please enter the description as it was meant to be below.", message: nil, preferredStyle: .alert)
        let alert4 = UIAlertController(title: "Is the below text meant to be a month?", message: tesstext[manualloop], preferredStyle: .alert)
        let alert5 = UIAlertController(title: "Please enter the month number it was meant to be below.", message: nil, preferredStyle: .alert)
        let alert6 = UIAlertController(title: "Is the below text meant to be a day?", message: tesstext[manualloop], preferredStyle: .alert)
        let alert7 = UIAlertController(title: "Please enter the number of day it was meant to be below.", message: nil, preferredStyle: .alert)
        let alert8 = UIAlertController(title: "Is the below text meant to be a time?", message: tesstext[manualloop], preferredStyle: .alert)
        let alert9 = UIAlertController(title: "Input intended time value in as 00:00 AM/PM - 00:00 AM/PM.", message: tesstext[manualloop], preferredStyle: .alert)
        let alert10 = UIAlertController(title: "Incorrect format.  Please re-enter.", message: nil, preferredStyle: .alert)
        var sender = 0
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert2, animated: true)
        }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                self.topMostController().dismiss(animated: true, completion: nil)
                self.topMostController().present(alert4, animated: true)
            }))
        
        alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.describer = self.tesstext[self.manualloop]
            self.NextIterate()
            self.topMostController().dismiss(animated: true, completion: nil)
            
        }))
        alert2.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert3, animated: true)
        }))
        
        alert3.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input intended description here."
        })
        
        alert3.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let input = alert3.textFields?.first?.text {
                self.describer = input
                self.NextIterate()
                self.topMostController().dismiss(animated: true, completion: nil)
            }
        }))
        
        alert4.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert5, animated: true)
        }))
        
        alert4.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert6, animated: true)
        }))
        
        alert5.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input intended month numeric value here."
        })
        
        alert5.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let input = alert5.textFields?.first?.text {
                if(Int(input) != nil)
                {
                self.monthnumber = Int(input)!
                self.NextIterate()
            }
                else
                {
                    sender = 5
                    self.topMostController().dismiss(animated: true, completion: nil)
                    self.topMostController().present(alert10, animated: true)
                }
            }}))
        
        alert6.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert7, animated: true)
        }))
        
        alert6.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert8, animated: true)
        }))
        
        alert7.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input intended numeric day value here."
        })
        
        alert7.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let input = alert7.textFields?.first?.text {
                if(Int(input) != nil)
                {
                    self.finaldayvalue = input
                    self.daymemory = Int(input)!
                    self.NextIterate()
                }
                else
                {
                    sender = 7
                    self.topMostController().dismiss(animated: true, completion: nil)
                    self.topMostController().present(alert10, animated: true)
                }
            }}))
        
        alert8.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert9, animated: true)
        }))
        
        alert8.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            if(self.manualloop < 34) {
            self.manualloop += 1
            self.topMostController().dismiss(animated: true, completion: nil)
            self.GenerateEvent()
            
            }
            else {
                self.topMostController().dismiss(animated: true, completion: nil)
                self.CompletionAlert()
            }
        }))
        
        alert9.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input intended time value in 00:00 AM/PM - 00:00 AM/PM."
        })
        
        alert9.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let input = alert9.textFields!.first?.text {
                let inputcheck = self.matches(for: "\\d{1,2}:\\d\\d \\w{0,2} - \\d{1,2}:\\d\\d\\s\\w{0,2}", in: input)
                if(!inputcheck[0].isEmpty)
                {
                    self.timecontained = 1
                    self.time.append(inputcheck[0])
                    self.GenerateEvent()
                    self.topMostController().dismiss(animated: true, completion: nil)
                }
                else
                {
                    sender = 9
                    self.topMostController().dismiss(animated: true, completion: nil)
                    self.topMostController().present(alert10, animated: true)
                }
            }}))
        
        
        
        
        
        alert10.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if(sender == 5) {
                self.topMostController().dismiss(animated: true, completion: nil)
                self.topMostController().present(alert5, animated: true)
            }
            else if(sender == 7) {
                self.topMostController().dismiss(animated: true, completion: nil)
                self.topMostController().present(alert7, animated: true)
            }
            else if(sender == 9) {
                self.topMostController().dismiss(animated: true, completion: nil)
                self.topMostController().present(alert9, animated: true)
            }
        }))
        
        
        
        
        
        self.topMostController().dismiss(animated: true, completion: nil)
        self.topMostController().present(alert, animated: true)
        }
    
    //Below correct view presentation errors.
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
            
    //Below executes query to API to attempt event insertion.
    func addEvent(_ event: GTLRCalendar_Event) {
        iterationvalue = 1
        //let selectedCalendar = GTLRCalendar_CalendarListEntry()
        //let calendarID = selectedCalendar.identifier
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        query.fields = "id"
        Service.executeQuery(
            query,
            completionHandler: {(_ callbackTicket:GTLRServiceTicket,
                _  event:GTLRCalendar_Event,
                _ callbackError: Error?) -> Void in}
                as? GTLRServiceCompletionHandler
        )
        
        if(manualloop < 34)
        {
            NextIterate()
            GenerateEvent()
        }
        else {
            CompletionAlert()
        }
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
    */
    func CompletionAlert() {
        let alert = UIAlertController(title : "Event generation completed!  Check your Google Calendar to verify and make corrections.", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.handleLogout()
            self.signInButton.isHidden = false
            self.output.isHidden = true
        })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func FailureAlert() {
        let alert = UIAlertController(title : "Unable to detect calendar events.  No events generated.", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.handleLogout()
            self.signInButton.isHidden = false
            self.output.isHidden = true
        })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title : String, message: String) {
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
            //print(tesstext)
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .singleColumn
            tesseract.image = image.g8_blackAndWhite()
            var x = [12, 485, 1057, 1646, 2223, 2806, 3404, 12, 501, 1069, 1635, 2211, 2793, 3385, 21, 525, 1076, 1641, 2210, 2780, 3364, 17, 533, 1085, 1644, 2202, 2765, 3345, 12, 540, 1093, 1645, 2199, 2761, 3323]
            var y = [326, 341, 358, 369, 390, 388, 390, 820, 843, 856, 853, 875, 891, 897, 1289, 1304, 1313, 1333, 1348, 1367, 1380, 1744, 1759, 1778, 1791, 1813, 1831, 1861, 2186, 2211, 2232, 2244, 2262, 2282, 2306]
            var height = [445, 460, 458, 468, 451, 460, 487, 434, 428, 427, 459, 424, 412, 447, 435, 433, 426, 442, 435, 448, 429, 410, 405, 415, 417, 412, 417, 422, 434, 414, 408, 425, 421, 429, 422]
            var width = [434, 549, 555, 549, 558, 565, 582, 455, 543, 542, 548, 550, 562, 581, 478, 526, 537, 535, 541, 549, 567, 487, 523, 534, 528, 537, 546, 559, 513, 527, 529, 517, 524, 535, 557]
            
            for (index, values) in x.enumerated() {
                
            tesseract.rect = CGRect(x: x[index], y: y[index], width: width[index], height: height[index])
            tesseract.recognize()
                tesstext.append(tesseract.recognizedText)
                //print(tesstext[index])
            }
            

        }
        //print(tesstext)
        GenerateEvent()
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


