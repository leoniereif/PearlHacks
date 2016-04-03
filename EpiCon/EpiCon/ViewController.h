//
//  ViewController.h
//  EpiCon
//
//  Created by Leonie Reif on 02/04/16.
//  Copyright © 2016 Leonie Reif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"


@interface ViewController : UIViewController {
    GraphView *graphView;
    __weak IBOutlet UIButton *connectButton;
    UIButton *button;
}

@property (strong, nonatomic) GraphView *graphView;
@property (strong, nonatomic) UIButton *button;

@end

