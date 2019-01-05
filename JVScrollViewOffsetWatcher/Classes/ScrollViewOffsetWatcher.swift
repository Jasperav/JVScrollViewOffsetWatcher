import UIKit

/// Since the amazing delegate pattern of Cocoa
/// we have to get a bit of help of the developer.
/// The delegate of the scroll view needs to listen to the
/// func scrollViewDidScroll(_ scrollView: UIScrollView)
/// method. There should the call to didScroll() be.
public protocol OffsetWatchableScrollView: UITableView {
    var didScroll: (() -> ())! { get set }
}

/// Watch an offset for a scroll view.
/// Useful for example pagening.
open class ScrollViewOffsetWatcher<T: OffsetWatchableScrollView> {
    /// The scroll view to watch.
    private unowned let scrollView: T
    
    /// The minimum offset to watch.
    /// If the offset is hit, offsetIsHit() will be called.
    private let minimumOffsetToWatch: CGFloat
    private let offsetIsHit: (() -> ())
    
    /// Indicates if we need to notify the user about the
    /// event that the offset is hit.
    private var watching = true
    
    public init(scrollView: T, minimumOffsetToWatch: CGFloat, offsetIsHit: @escaping (() -> ())) {
        self.scrollView = scrollView
        self.minimumOffsetToWatch = minimumOffsetToWatch
        self.offsetIsHit = offsetIsHit
        
        scrollView.didScroll = { [unowned self] in
            guard self.watching else { return }
            
            self.calculateOffset()
        }
    }
    
    /// Start being notified about that the offset was hit.
    open func watch() {
        watching = true
        
        calculateOffset()
    }
    
    /// Stop being notified.
    open func unwatch() {
        watching = false
    }
    
    private func calculateOffset() {
        let totalHeight = scrollView.contentSize.height - scrollView.bounds.height
        let currentPosition = scrollView.contentOffset.y
        let correctedValue = totalHeight - currentPosition - minimumOffsetToWatch
        
        guard correctedValue < 0 else { return }
        
        watching = false
        
        offsetIsHit()
    }
}
