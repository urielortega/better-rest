//
//  ContentView.swift
//  BetterRest
//
//  Created by Uriel Ortega on 14/04/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    private var bedtimeResult: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 // Hours in seconds
            let minute = (components.minute ?? 0) * 60 // Minutes in seconds
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .center, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("Number of coffee cups", selection: $coffeeAmount) {
                        ForEach(0..<21) { coffeeCups in
                            Text(String(coffeeCups))
                        }
                    }
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Recommended bedtime")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Text(bedtimeResult)
                        .font(.largeTitle.bold())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
