//
//  WikiWebViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 8/8/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikiWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) NSString *urlString;
@property (nonatomic, strong) NSString *pageTitle;

@end
