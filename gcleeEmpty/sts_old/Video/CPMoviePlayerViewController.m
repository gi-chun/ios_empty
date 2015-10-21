//
//  CPMoviePlayerViewController.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPMoviePlayerViewController.h"

@interface CPMoviePlayerViewController ()

@end

@implementation CPMoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setWantsFullScreenLayout:YES];
    
    if (self.view.frame.size.width > self.view.frame.size.height) {
        viewHeight = self.view.frame.size.width;
        viewWidth = self.view.frame.size.height;
    }
    else {
        viewHeight = self.view.frame.size.height;
        viewWidth = self.view.frame.size.width;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
        self.moviePlayer.view.frame = CGRectMake(0, -20, viewWidth, viewHeight);
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
        self.moviePlayer.view.frame = CGRectMake(0, -20, viewWidth, viewHeight);
    }
    
    return YES;
}


@end
