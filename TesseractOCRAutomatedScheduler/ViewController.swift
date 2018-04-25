//
//  ViewController.swift
//  TesseractOCRAutomatedScheduler
//
//  Created by Mihai Pocse on 4/15/18.
//  Copyright © 2018 Mihai Pocse. All rights reserved.
//

//Importing Cocoapod and foundation files.

import UIKit
import TesseractOCR
import GoogleSignIn
import GoogleAPIClientForREST
import Foundation






class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    /*To Avoid complications with variable dependencies, much of the code is housed in the View Controller with the views and UI elements being conveyed programmatically.  Storyboard has been disabled for thie project. */
    
    
    // Scope added to grant editing and viewing rights to the calendar for accessing   // Google Calendar.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    //Adds the initializers for the Calendar Service, Google Sign-In button, and the string Array that Tesseract will fill with its read String values.
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
    var yearnumber = 0
    
    // Below snippet does not work in current version.  Meant to show loading icon when // Tesseract processing takes longer than expected to generate.
    
    let activityindicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100 , y: 200, width: 50, height: 50)) as UIActivityIndicatorView
    
    
    
    
    
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        signInButton.frame = CGRect(x:0, y: 0, width: 200, height: 300)
        signInButton.center = view.center
        
        // UI Elements Added Below.
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        label2.center = CGPoint(x: 190, y: 240)
        label.center = CGPoint(x: 190, y: 280)
        label2.textAlignment = .center
        label.textAlignment = .center
        label2.text = "Tesseract/OCR Automated Scheduler!"
        label.text = "Please Click Sign In To Continue!"
        label.textColor = UIColor(r: 255, g: 255, b: 255)
        label2.textColor = UIColor(r: 255, g: 255, b: 255)
        label2.adjustsFontSizeToFitWidth = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label2.textAlignment = .center
        self.view.addSubview(label)
        self.view.addSubview(label2)
        
        
        // Below snippet does not work in current version.  Meant to show loading icon when // Tesseract processing takes longer than expected to generate.
        
        activityindicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityindicator)
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        
         output.frame = view.bounds
         output.isEditable = false
         output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
         output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
         output.isHidden = true
        
        // Below snippet does not work in current version.  Meant to show loading icon when // Tesseract processing takes longer than expected to generate.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        view.addSubview(output);
    }
    
    //Function for processing Google Sign-Out functionality.
    @objc func handleLogout() {
        self.signInButton.isHidden = false
        //self.output.isHidden = true
        GIDSignIn.sharedInstance().signOut()
    }
    
    //Function for handling Sign-In Processing for Google.
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
            
        }
        
        
    }
    
    /* Below function prompts the user for a 4 digit year value which is later referenced when creating the events.  Upon completion, will call GenerateEvents() to begin processing of Tesseract’s input. */
    func YearCheck() {
        let alert = UIAlertController(title : "Pleae enter the year as a four digit value", message: nil, preferredStyle: .alert)
        
        /* Alert2 handles error catching if value entered does not match 4 digit requirement. (converts shorter numbers to 000X so user should be cautious when entering digits. */
        let alert2 = UIAlertController(title : "Invalid year.  Please try again.", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter the four digit year value here"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            
            if let input = alert.textFields?.first?.text {
                if(Int(input) != nil) {
                    if(input.contains(String(format: "%04d", Int(input)!))) {
                        self.topMostController().dismiss(animated: true, completion: nil)
                        self.yearnumber = Int(input)!
                        self.GenerateEvent()
                        
                    } else
                    {
                        self.topMostController().dismiss(animated: true, completion: nil)
                        self.topMostController().present(alert2, animated: true)
                    }
                    
                }
                else
                {
                    self.topMostController().dismiss(animated: true, completion: nil)
                    self.topMostController().present(alert2, animated: true)
                }
                
            }}))
        
        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.topMostController().dismiss(animated: true, completion: nil)
            self.topMostController().present(alert, animated: true)
            
        }))
        
        self.topMostController().dismiss(animated: true, completion: nil)
        self.topMostController().present(alert, animated: true)
    }
    
    
    //Below function used extensively throughout code in order to enable easier     // pattern matching of regular expressions when parsing Tesseract’s string values.
    
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
    
    /* The most important function in the entire code.  Generate events contains a multi-level if-statement along with various loops to parse tesstext’s information.  This function references both CreateEvents() for the actual passing on of data to Google Calendar, as well as AlertGenerato() to catch any failed lines and replace those values with user inputs to insure the greatest degree of accuracy possible with the given tesseract array. */
    
    func GenerateEvent()
    {
        //print(tesstext)
        tesstextcheck = tesstext[manualloop]
        
        /* Below contains an if statement check to verify that there isn’t a time value from the user already stored.  If not, then time variable will != nil in the event that there is a match for a time entry from the tesstext line at array value of manualloop. */
        
        if(timecontained != 1){
            //print(tesstext[manualloop])
            time = matches(for: "\\d{1,2}:\\d\\d \\w{1,2} - \\d{1,2}:\\d\\d", in: tesstext[manualloop])
            //print (tesstext[manualloop])
            //print(time)
        } else {
            print(time[0])
            
        }
        //Below is a regex match for any 1-2 digit values representing days in tesstext.
        var daymatch = matches(for: "^\\d{1,2}\\n", in: tesstext[manualloop])
        var fulltime = [String]()
        
        //Below is a short loop of a 12 month dictionary to identify if monthname values //are present.  If present, will assign monthunmber to dictionaries key value.
        
        for(monthdigit, monthname) in month {
            
            if(tesstext[manualloop].range(of: monthname) != nil)
            {
                monthnumber = monthdigit
                nameofmonth = monthname
                
            }
        }
        /* The first of three ranges used to assess alert status for values.  If these ranges are nil, it represents a problem with the inputted string requiring user intervention. */
        let range1 = tesstext[manualloop].range(of: nameofmonth)
        if(time.isEmpty == false)
        {
            if(timecontained == 1){
                print(time[0])
            }
            print(time[0] + " time isn't empty.")
            time[0] = time[0].trimmingCharacters(in: .whitespacesAndNewlines)
            describer = time[0]
            /*Time has an extra layer of complexity as the start and end times need to be separated.  This is done by splitting it into an array of string coponents based on the common time and hour/minute dividers. Spaces are used as dividers to eliminate them from inclusion. */
            fulltime = time[0].components(separatedBy: ["-",":"," "])
            fulltime = fulltime.filter { $0 != ""}
            /* TODO: confirm filter is working as intended.
             Below checks PM or AM status to perform necessary military time conversions on  either the start or end times.  Check AlertGenerator logic as it may contain issues. */
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
        
        /* Below expression matches array value for day and generates variable in 2 digit numerical format.  Dayiterate and daymemory are used as fill-in values in the event that the parser is unable to locate a day within the tesstext array index location. */
        
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
        
        
        
        //Below prints a test to confirm present month values (tracking loop purposes) and //establishes the remaining day and time range values.
        
        print(nameofmonth + " " + String(monthnumber) + " month isn't empty")
        var range2 = tesstext[manualloop].range(of: describer)
        
        if(self.time.count > 0) {
            range2 = tesstext[manualloop].range(of: self.time[0])
        }
        let range3 = tesstext[manualloop].range(of: String(finaldayvalue))
        tesstextcheck = tesstextcheck.replacingOccurrences(of: "^\\d{1,2}\\n", with: "", options: .regularExpression)
        tesstextcheck = tesstextcheck.trimmingCharacters(in: .whitespacesAndNewlines)
        print(tesstextcheck)
        //Below helps track variable statuses in sequence of loop.
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
        
        /* Below logic runs a long sequence of logic checks to determine if the day, time, and month values are all outputting as expected.  Any failures will result in an AlertGenerator.  Any Successes will get passed to the EventCreator.  If none of the conditions for the above are met, will simply skip the value (if tesstext at index value contains nothing for example.)  If manualloop has reached the end of its set, will also output a CompletionAlert notifying the user that the program completed successfully. */
        
        if(((((monthnumber == 0 || finaldayvalue.isEmpty || time.isEmpty) && (range1 == nil && ((range3 == nil || (range2 == nil && !tesstextcheck.isEmpty))) || (!finaldayvalue.isEmpty && Int(finaldayvalue)! > 31)) && oddday != 1)) || (range1 == nil && range2 == nil && range3 == nil) && oddday != 1) && !tesstext[manualloop].isEmpty)  {
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
    
    /* NextIterate is called by the CreateEvents() function and as a response to a few edge cases.  IF called by CreateEvents, iterationvalue will be set to 1, notifying it to reset all previously stored values for the next iteration.  NextIterate is also called by the AlertGenerator in order to either have events created from the user’s input, or, if a complete set couldn’t be established, will use it to skip to the next tesstext entry. */
    
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
        else if(monthnumber != 0 && !String(finaldayvalue).isEmpty && ((!self.starttime.isEmpty && !self.endtime.isEmpty) || !describer.isEmpty) && self.manualloop < 34) {
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

/* Below CreateEvents() function handles the reformatting of inputted data into date objects readable by Google Calendar.It then creates the event object and passes it to the AddEvent() function. */
 
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
 let date = String(format: "%04d", yearnumber) + "-" + String(format: "%02d", monthnumber) + "-" + String(finaldayvalue)
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
 /* Alert Generator runs a number of checks to inform the user of potential errors and pull user inputs for correcting data in order to improve accuracy of results. */
 func AlertGenerator() {
 var dayerror = ""
 var montherror = ""
 var timeerror = ""
 if(monthnumber > 0)
 {
 montherror = "OK!"
 }
 else
 {
 montherror = "Not OK!"
 }
 if(!self.starttime.isEmpty && !self.endtime.isEmpty){
 timeerror = "OK!"
 }
 else
 {
 timeerror = "Not OK!"
 }
 if(!String(finaldayvalue).isEmpty){
 dayerror = "OK!"
 }
 else
 {
 dayerror = "Not OK!"
 }
 
 let alert = UIAlertController(title: "Is the below text meant to be a description of an event?  Code Status: Day = " + dayerror + " Month = " + montherror + " Time = " + timeerror, message: tesstext[manualloop], preferredStyle: .alert)
 let alert2 = UIAlertController(title: "Is it correct as is?", message: nil, preferredStyle: .alert)
 let alert3 = UIAlertController(title: "Please enter the description as it was meant to be below.", message: nil, preferredStyle: .alert)
 let alert4 = UIAlertController(title: "Is the below text meant to be a month?  Code Status: Day = " + dayerror + " Month = " + montherror + " Time = " + timeerror, message: tesstext[manualloop], preferredStyle: .alert)
 let alert5 = UIAlertController(title: "Please enter the month number it was meant to be below.", message: nil, preferredStyle: .alert)
 let alert6 = UIAlertController(title: "Is the below text meant to be a day?  Code Status: Day = " + dayerror + " Month = " + montherror + " Time = " + timeerror, message: tesstext[manualloop], preferredStyle: .alert)
 let alert7 = UIAlertController(title: "Please enter the number of day it was meant to be below.", message: tesstext[manualloop], preferredStyle: .alert)
 let alert8 = UIAlertController(title: "Is the below text meant to be a time?  Code Status: Day = " + dayerror + " Month = " + montherror + " Time = " + timeerror, message: tesstext[manualloop], preferredStyle: .alert)
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
 // TODO: add extra steps for checking missing values:
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
 if(Int(input) != nil) {
 if(input.contains(String(format: "%02d", Int(input)!))) {
 
 self.monthnumber = Int(input)!
 
 if(String(self.finaldayvalue).isEmpty) {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert7, animated: true)
 } else if(self.starttime.isEmpty || self.endtime.isEmpty){
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert9, animated: true)
 } else {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.NextIterate()
 
 }
 
 }
 else
 {
 sender = 5
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert10, animated: true)
 }
 
 
 }
 }
 
 }))
 alert5.addAction(UIAlertAction(title: "Not Correctable", style: .default, handler: { action in
 self.topMostController().dismiss(animated: true, completion: nil)
 self.NextIterate()
 }))
 
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
 if(Int(input) != nil) {
 if(Int(input)! <= 31 && Int(input)! > 0)
 {
 self.finaldayvalue = input
 self.daymemory = Int(input)!
 self.dayiterate += 1
 
 if(self.monthnumber == 0) {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert5, animated: true)
 } else if(self.starttime.isEmpty || self.endtime.isEmpty){
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert9, animated: true)
 } else {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.NextIterate()
 }
 }
 }
 else
 {
 sender = 7
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert10, animated: true)
 }
 }
 
 }
 
 ))
 
 alert7.addAction(UIAlertAction(title: "Not Correctable", style: .default, handler: { action in
 self.topMostController().dismiss(animated: true, completion: nil)
 self.NextIterate()
 }))
 
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
 if(self.time.count > 0) {
 self.time.insert(inputcheck[0], at: 0)
 }
 else
 {
 self.time.append(inputcheck[0])
 }
 
 if(self.monthnumber == 0) {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert5, animated: true)
 } else if(String(self.finaldayvalue).isEmpty) {
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert7, animated: true)
 } else {
 self.GenerateEvent()
 self.topMostController().dismiss(animated: true, completion: nil)
 }
 }
 } else
 {
 sender = 9
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert10, animated: true)
 }
 
 
 
 }))
 
 alert9.addAction(UIAlertAction(title: "Not Correctable", style: .default, handler: { action in
 self.topMostController().dismiss(animated: true, completion: nil)
 self.NextIterate()
 }))
 
 
 
 
 
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
 
 //Below corrects view presentation errors by insuring the presenter is always    // the top most view controller.
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
 
 //Notifies user that tesstext index has reached its conclusion and all events //are now generated.  Clicking OK performs Google Sign-Out.
 func CompletionAlert() {
 let alert = UIAlertController(title : "Event generation completed!  Check your Google Calendar to verify and make corrections.", message: nil, preferredStyle: .alert)
 let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
 self.handleLogout()
 self.signInButton.isHidden = false
 self.output.isHidden = true
 self.topMostController().dismiss(animated: true, completion: nil)
 })
 alert.addAction(ok)
 self.topMostController().present(alert, animated: true, completion: nil)
 }
 
 //Below notifies user if there were no detectable entries to parse for the calendar //in tesstext.
 
 func FailureAlert() {
 let alert = UIAlertController(title : "Unable to detect calendar events.  No events generated.", message: nil, preferredStyle: .alert)
 let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
 self.handleLogout()
 self.signInButton.isHidden = false
 self.output.isHidden = true
 })
 alert.addAction(ok)
 self.topMostController().dismiss(animated: true, completion: nil)
 self.topMostController().present(alert, animated: true, completion: nil)
 }
 //Not sure.  May deprecate.
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
 
 /* Below is the meet of the Tesseract aspect of the program.  Contains the tesseract object as well as its settings and creates a sequence of 4 unique calendar array values that should work for most calendars who’s images are of a similar size and angle.  Will likely fail on calendars of dissimilar proportions. */
 func performImageRecognition(_ image: UIImage) {
 
 
 // Below snippet does not work in current version.  Meant to show loading icon // when Tesseract processing takes longer than expected to generate.
 
 self.view.bringSubview(toFront: activityindicator)
 
 if let tesseract = G8Tesseract(language: "eng") {
 //print(tesstext)
 tesseract.engineMode = .tesseractCubeCombined
 tesseract.pageSegmentationMode = .singleColumn
 tesseract.image = image.g8_blackAndWhite()
 var x = [12, 485, 1057, 1646, 2223, 2806, 3404, 12, 501, 1069, 1635, 2211, 2793, 3385, 21, 525, 1076, 1641, 2210, 2780, 3364, 17, 533, 1085, 1644, 2202, 2765, 3345, 12, 540, 1093, 1645, 2199, 2761, 3323]
 var y = [326, 341, 358, 369, 390, 388, 390, 820, 843, 856, 853, 875, 891, 897, 1289, 1304, 1313, 1333, 1348, 1367, 1380, 1744, 1759, 1778, 1791, 1813, 1831, 1861, 2186, 2211, 2232, 2244, 2262, 2282, 2306]
 var height = [445, 460, 458, 468, 451, 460, 487, 434, 428, 427, 459, 424, 412, 447, 435, 433, 426, 442, 435, 448, 429, 410, 405, 415, 417, 412, 417, 422, 434, 414, 408, 425, 421, 429, 422]
 var width = [434, 549, 555, 549, 558, 565, 582, 455, 543, 542, 548, 550, 562, 581, 478, 526, 537, 535, 541, 549, 567, 487, 523, 534, 528, 537, 546, 559, 513, 527, 529, 517, 524, 535, 557]
 
 //Below performs the image recognition and output loop.
 for (index, values) in x.enumerated() {
 tesseract.rect = CGRect(x: x[index], y: y[index], width: width[index], height: height[index])
 tesseract.recognize()
 tesstext.append(tesseract.recognizedText)
 
 }
 
 
 
 }
 
 // Below snippet does not work in current version.  Meant to show loading icon // when Tesseract processing takes longer than expected to generate.
 
 self.activityindicator.stopAnimating()
 YearCheck()
 //activityIndicator.stopAnimating()
 }
 
 
 }
 
 
  /* 1 Below code provides extensions to enable smoother UI element transitions and added functionality to certain inset controls.  (Such as a logout on press for the cancel button on the image viewer.
 MARK: - UINavigationControllerDelegate */
 extension ViewController: UINavigationControllerDelegate {
 }
 
 
 // MARK: - UIImagePickerControllerDelegate Displays the imagepicker dialogue.
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
 let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
 
 self.handleLogout()
 })
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
 self.activityindicator.startAnimating()
 // 4
 
 
 dismiss(animated: true, completion: {
 self.performImageRecognition(scaledImage)
 })
 }
 }
 }
 
 
 /* MARK: - UIImage extension rescales images to match required input for Tesseract // recognition.  Due to the way the calendar is automatically segmented, size limitations are not as problematic for this project.  Images are scaled to match current calendar to increase potential for boundary boxes lining up on other calendar images. */
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
 
 //Extension to provide a shorthand for entering in programmatic recoloration of UI //elements.
 
 extension UIColor {
 convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
 self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
 }
 }
 
