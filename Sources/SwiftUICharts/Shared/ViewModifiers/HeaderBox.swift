//
//  HeaderBox.swift
//  LineChart
//
//  Created by Will Dale on 03/01/2021.
//

import SwiftUI

/**
 Displays the metadata about the chart as well as optionally touch overlay information.
 */
internal struct HeaderBox<T>: ViewModifier where T: CTChartData {
    
    @ObservedObject private var chartData: T
    private var lastDataPoint: T.DataPoint?
    private var prefixView: AnyView?
    private var padding: CGFloat?
    
    init(chartData: T, lastDataPoint: T.DataPoint?, prefixView: AnyView?, padding: CGFloat?) {
        self.chartData = chartData
        self.lastDataPoint = lastDataPoint
        self.prefixView = prefixView
        self.padding = padding
    }
    
    var titleBox: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey(chartData.metadata.title))
                .font(chartData.metadata.titleFont)
                .foregroundColor(chartData.metadata.titleColour)
            Text(LocalizedStringKey(chartData.metadata.subtitle))
                .font(chartData.metadata.subtitleFont)
                .foregroundColor(chartData.metadata.subtitleColour)
        }
    }
    var touchOverlay: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if chartData.infoView.isTouchCurrent {
                ForEach(chartData.infoView.touchOverlayInfo, id: \.id) { point in
                    HStack {
                        prefixView
                        chartData.infoValueUnit(info: point)
                            .font(chartData.chartStyle.infoBoxValueFont)
                            .foregroundColor(chartData.chartStyle.infoBoxValueColour)
                    }
                    if let priceDiff = point.priceDiff {
                        Text(priceDiff)
                            .font(chartData.chartStyle.infoBoxDescriptionFont.bold())
                            .foregroundColor(point.color)
                    }
                    chartData.infoDescription(info: point)
                        .font(chartData.chartStyle.infoBoxDescriptionFont)
                        .foregroundColor(chartData.chartStyle.infoBoxDescriptionColour)
                }
            } else {
                if let lastDataPoint = lastDataPoint {
                    HStack {
                        prefixView
                        chartData.infoValueUnit(info: lastDataPoint)
                            .font(chartData.chartStyle.infoBoxValueFont)
                            .foregroundColor(chartData.chartStyle.infoBoxValueColour)
                    }
                    if let priceDiff = lastDataPoint.priceDiff {
                        Text(priceDiff)
                            .font(chartData.chartStyle.infoBoxDescriptionFont.bold())
                            .foregroundColor(lastDataPoint.color)
                    }
                    chartData.infoDescription(info: lastDataPoint)
                        .font(chartData.chartStyle.infoBoxDescriptionFont)
                        .foregroundColor(chartData.chartStyle.infoBoxDescriptionColour)
                }
            }
        }
    }
    
    internal func body(content: Content) -> some View {
        Group {
            #if !os(tvOS)
            switch chartData.chartStyle.infoBoxPlacement {
            case .floating:
                VStack(alignment: .leading) {
                    titleBox
                    content
                }
            case .infoBox:
                VStack(alignment: .leading) {
                    titleBox
                    content
                }
            case .header:
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        HStack(spacing: 0) {
                            titleBox
                            Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                            touchOverlay
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        
                    }
                    .padding(padding ?? 0)

                    content
                }
            }
            #elseif os(tvOS)
            if chartData.isGreaterThanTwo() {
                VStack(alignment: .leading) {
                    titleBox
                    content
                }
            } else { content }
            #endif
        }
    }
}

extension View {
    /**
     Displays the metadata about the chart.
     
     Adds a view above the chart that displays the title and subtitle.
     If infoBoxPlacement is set to .header then the datapoint info will
     be displayed here as well.
     
     - Parameter chartData: Chart data model.
     - Returns: A  new view containing the chart with a view above
     to display metadata.
     */
    public func headerBox<T:CTChartData>(chartData: T, lastDataPoint: T.DataPoint?,
                                         prefixView: AnyView?, padding: CGFloat?) -> some View {
        self.modifier(HeaderBox(chartData: chartData, lastDataPoint: lastDataPoint,
                                prefixView: prefixView, padding: padding))
    }
}
