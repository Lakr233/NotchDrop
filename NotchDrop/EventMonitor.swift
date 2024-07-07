import AppKit

public class EventMonitor {
    private var globalMonitor: AnyObject?
    private var localMonitor: AnyObject?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handler(event)
            return event
        } as AnyObject?
    }

    public func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        globalMonitor = nil
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        localMonitor = nil
    }
}
