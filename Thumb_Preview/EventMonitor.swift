//
//  EventMonitor.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/27/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

public class GlobalEventMonitor {
    fileprivate var monitor: Any?
//    private let mask: NSEvent.EventTypeMask
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> Void

//    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }

}


public class LocalEventMonitor {
    fileprivate var monitor: Any?
    //    private let mask: NSEvent.EventTypeMask
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent) -> NSEvent?

    public init(mask: NSEventMask, handler: @escaping (NSEvent) -> NSEvent?) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }

}

