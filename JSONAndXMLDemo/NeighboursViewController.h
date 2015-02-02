//
//  NeighboursViewController.h
//  JSONAndXMLDemo
//
//  Created by Gabriel Theodoropoulos on 24/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NeighboursViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tblNeighbours;


@end
