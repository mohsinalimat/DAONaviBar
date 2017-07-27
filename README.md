# DAONaviBar
DaoNaviBar is a navigation bar with smooth auto-scrolling animation.

![Image of navibar](https://media.giphy.com/media/aMkjGZk8fA8HC/giphy.gif)

## Installation ##
### CocoaPods ###
```
pod 'DAONaviBar', '~> 0.3'
```

### Usage ###
```objective-c
#import "DAONaviBar.h"

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DAONaviBar sharedInstance] setupWithController:self scrollView:self.scrollViewToTrack];
}
```
