//
//  EventMonitor.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/27/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa


protocol EventMonitor {
    // could make the monitor a protocol property and check for nil
    // but this seems a bit cleaner
    var isMonitoring: Bool { get }
    func start()
    func stop()
}

public class GlobalEventMonitor: EventMonitor {
    fileprivate var monitor: Any?
//    private let mask: NSEvent.EventTypeMask
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> Void
    var isMonitoring: Bool

//    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
        isMonitoring = false
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        isMonitoring = true
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
        isMonitoring = false
    }

}


public class LocalEventMonitor: EventMonitor {
    fileprivate var monitor: Any?
    //    private let mask: NSEvent.EventTypeMask
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent) -> NSEvent?
    var isMonitoring: Bool

    public init(mask: NSEventMask, handler: @escaping (NSEvent) -> NSEvent?) {
        self.mask = mask
        self.handler = handler
        isMonitoring = false
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
        isMonitoring = true
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
        isMonitoring = false
    }

}

