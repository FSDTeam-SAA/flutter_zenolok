//
//  CalendarWidgetBundle.swift
//  CalendarWidget
//
//  Created by FSD_APP on 29/11/25.
//

import WidgetKit
import SwiftUI

@main
struct CalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalendarWidget()
        CalendarWidgetControl()
        CalendarWidgetLiveActivity()
    }
}
