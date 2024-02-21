//
//  ContentView.swift
//  CalculatorIOS
//
//  Created by cynthiaw on 2/8/24.
//

import SwiftUI

enum CalcButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case zero = "0"
    case add = "+"
    case subtract = "-"
    case multiply = "x"
    case divide = "\u{00F7}"
    case equal = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "-/+"
    
    var buttonColor: Color {
        switch self{
        case .add, .subtract, .multiply, .divide, .equal:
            return .blue
        case .clear, .negative, .percent:
            return Color(UIColor(red: 116/255.0, green: 186/255.0, blue: 255/255.0, alpha: 1))
        default:
            return Color(UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1))
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, equal, none
}

struct ContentView: View {
    
    @State var current = ""
    @State var display = ""
    @State var leftNumber: Double?
    @State var rightNumber = 0.0
    @State var currentOperation: Operation = .none
    @State private var history: [String] = []
    @State private var showHistory = false
    @State var operationSymbol = ""

    
    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .add],
        [.seven, .eight, .nine, .subtract],
        [.four, .five, .six, .multiply],
        [.one, .two, .three, .divide],
        [.zero, .decimal, .equal],
        
    ]
    
    let fontSizeMapping: [Range<Int>: CGFloat] = [
        0..<7: 96,  // Font size 96 for text length 0-6
        7..<8: 80,
        8..<9: 72,
        9..<10: 64,
        10..<11: 56
    ]
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack{
                HStack{
                    
                    //History button
                    Button(action: {
                        self.showHistory.toggle()
                    }) {
                        Image(systemName: "clock")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                           
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    
                    .sheet(isPresented: $showHistory) {
                        HistoryModalView(history: self.$history, isPresented: self.$showHistory)
                    }
                    Spacer()
                }
                Spacer() //To push everything to the bottom
                
                HStack{
                    // Text display
                    Spacer()
                    
                    //Text("\(formatNumber(display))")
                    Text(display.count > 10 ? "\(formatNumber(display))" : formatIntegers(displayedNumber: display).prefix(10))
                        .font(.system(size: fontSize(for: display)))
                        //.font(.system(size: 100))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding()
                
                // Buttons
                ForEach(buttons, id:\.self){ row in
                    HStack(spacing: 12){
                        ForEach(row, id: \.self){ item in
                            Button(action: {
                                self.screenTap(button: item)
                            }, label: {
                                Text(item.rawValue)
                                    .font(.system(size: 32))
                                    .frame(
                                        width: self.buttonWidth(item: item),
                                        height: self.buttonHeight()
                                    )
                                    .background(item.buttonColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(self.buttonWidth(item: item)/2)
                                
                            })
                        }
                    }
                    .padding(.bottom, 3)
                }
                    
                
            }
        }
    }
    
    //did user tap on number, operator or clear
    func screenTap(button: CalcButton){
        switch button {
        case .add, .subtract, .multiply, .divide, .equal:
            if currentOperation != .none && current != "0" {
                calculateResult(currentValue: Double(self.current) ?? 0, leftNumber: leftNumber ?? 0)
            }
            
            if button == .add{
                self.currentOperation = .add
                operationSymbol = button.rawValue
            }
            else if button == .subtract {
                self.currentOperation = .subtract
                operationSymbol = button.rawValue

            }
            else if button == .multiply {
                self.currentOperation = .multiply
                operationSymbol = button.rawValue

            }
            else if button == .divide {
                self.currentOperation = .divide
                operationSymbol = button.rawValue

            }
            
            if current != "0" {
                self.display = String(current)
                self.leftNumber = Double(current)
                self.current = "0"
            }
        case .clear:
            clearAll()
            
        case .decimal, .negative, .percent:
            if button == .decimal {
                self.current += button.rawValue
                self.display = self.current
            }
            else if button == .negative {
                self.current = "-"
                self.display = self.current
            }
            else if button == .percent {
                self.current = String((Double(current) ?? 0)/100)
                self.display = self.current
                self.leftNumber = Double(self.current)
                self.current = "0"
            }
        default:
            let number = button.rawValue
            if self.current == "0" {
                current = number
            }
            else{
                current += number
            }
            self.display = self.current
        }
        
    }
    
    func calculateResult(currentValue: Double, leftNumber: Double){
        self.rightNumber = currentValue
        
        switch self.currentOperation {
        case .add:
            self.current = String(leftNumber + currentValue)
            
        case .subtract:
            self.current = String(leftNumber - currentValue)

        case .multiply:
            self.current = String(leftNumber * currentValue)

        case .divide:
            if currentValue == 0.0 {
                self.current = "Error"
                clearAll()
            }
            else{
                self.current = String(leftNumber / currentValue)
            }
        case .equal:
            current = String(currentValue)
        case .none:
            break
        }
        
        // Add calculation to history log
        addToHistory(result: current)
        currentOperation = .none
    }
    
    func addToHistory(result: String){
        let historyEntry = "\(formatIntegers(displayedNumber: String(leftNumber ?? 0))) \(operationSymbol) \(formatIntegers(displayedNumber: String(rightNumber))) \n = \(formatIntegers(displayedNumber: result))"
        history.append(historyEntry)
    }
    
    func clearAll(){
        self.current = ""
        self.display = ""
        self.leftNumber = nil
        self.rightNumber = 0.0
        self.currentOperation = .none
        self.operationSymbol = ""
    }
    
    private func fontSize(for text: String) -> CGFloat {
        for(range, fontSize) in fontSizeMapping {
            if range.contains(text.count) {
                return fontSize
            }
            
        }
        // Default font size if no matching range is found
        return fontSizeMapping[10..<11] ?? 56
        
    }
    
    // format number to only show 10 digits with exponent
    private func formatNumber(_ numberS: String) -> String {
            guard let number = Double(numberS) else { return "" }
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 5
            var formattedString = formatter.string(from: NSNumber(value: number)) ?? ""
            formattedString = formattedString.replacingOccurrences(of: "E", with: "e")

        return formattedString
    }
    
    func formatIntegers(displayedNumber: String) -> String {
        
        if let doubleValue = Double(displayedNumber), doubleValue.rounded(.down) == doubleValue {
            // If the displayed number is a whole number, display it without decimal points
            return String(format: "%.0f", doubleValue)

        }
        return String(displayedNumber)
    }
    
    func buttonWidth(item: CalcButton) -> CGFloat{
        if item == .zero{
            return (UIScreen.main.bounds.width - (4*12)) / 4 * 2//4 represents the number of paddings and 12 is the padding amount
        }
        return (UIScreen.main.bounds.width - (5*12)) / 4
    }
    
    func buttonHeight() -> CGFloat{
        return (UIScreen.main.bounds.width - (5*12)) / 4
    }
}




struct HistoryModalView : View {
    @Binding var history: [String]
    @Binding var isPresented: Bool
    
    // State variable to track the vertical offset of the swipe gesture
    @State private var offsetY: CGFloat = .zero
    
    var body: some View {
        GeometryReader {geometry in
            ZStack{
                Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack {
                    Text("History")
                        .font(.title)
                        .padding(25)
                        .bold()
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    
                    ScrollViewReader { scrollView in
                        ScrollView{
                            VStack(alignment: .trailing, spacing: 10){
                                ForEach(history, id: \.self) {entry in
                                    Text(entry)
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 15)
                                        .padding(.trailing, 15)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)// Align text to the right
                                        .id(entry) // Identify each text view with its entry string
                                    
                                }
                            }
                            .padding()
                        }
                        .onAppear {
                            // Scroll to the bottom of the ScrollView when it appears
                            scrollView.scrollTo(history.last, anchor: .bottom)
                        }
                    }
                
                    
                    Spacer()
                    
                    // Clear history button
                    Button(action: {
                        self.clearHistory()
                    }) {
                        Text("Clear History")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            
                    }
                    .padding()
                    
                }
            
                //Swipe down to close
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.offsetY = value.translation.height
                        }
                        .onEnded { value in
                            // Dismiss the modal view when swipe down exceeds threshold
                            if self.offsetY > geometry.size.height / 2 {
                                self.dismiss()
                            }
                            else {
                                self.offsetY = .zero
                            }
                        }
                )
                // Apply the offset based on the swipe gesture
                .offset(y: self.offsetY)
                
                //                // Close button
                //                Button(action: {
                //                    //Dismiss the modal view
                //                    self.dismiss()
                //                }) {
                //                    Text("Close")
                //                        .font(.headline)
                //                        .foregroundColor(.white)
                //                        .padding()
                //                        .background(Color.blue)
                //                        .cornerRadius(10)
                //                }
                //                .padding()
                //            }
                
            }

        }
        
    }
    
    func clearHistory(){
        self.history = []
    }
    private func dismiss(){
        // Dismiss the modal view by setting the binding variable to false
        self.isPresented = false
    }
    
}

#Preview {
    ContentView()
}
