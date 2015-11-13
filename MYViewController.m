//
//  MYViewController.m
//  MYBlurIntroductionView-Example
//
//  Created by Matthew York on 10/16/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import "MYViewController.h"

//#import "MYCustomPanel.h"

@interface MYViewController ()

@end

@implementation MYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    //Calling this methods builds the intro and adds it to the screen. See below.
    [self buildIntro];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Build MYBlurIntroductionView

-(void)buildIntro{
    
    //gclee
//    NSString *url_Img1 = @"http://opensum.in/app_test_f1";
//    NSString *url_Img2 = @"45djx96.jpg";
//    
//    NSString *url_Img_FULL = [url_Img1 stringByAppendingPathComponent:url_Img2];
//    
//    NSLog(@"Show url_Img_FULL: %@",url_Img_FULL);
//    view_Image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULL]]];
    
    //////////////////////////////////////////////
//    NSString *imgURL = @"imagUrl";
//    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
//    
//    [YourImgView setImage:[UIImage imageWithData:data]];
    
    //////////////////////////////////////////////
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *imgURL = @"imagUrl";
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
//        
//        //set your image on main thread.
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [YourImgView setImage:[UIImage imageWithData:data]];
//        });    
//    });
    
    ////////////////////////////////////////////////////
//    NSData *imageUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"Your image URL Here"]];
//    [UIImage imageWithData:imageUrl];
    
    ///////////////////////////////////////////////////////
     //ImageViewname.image = [UIImage imageNamed:@"test.png"];
    
    /////////////////////////////////////////////////////////
    // https request
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    
//#pragma mark NSURLConnection delegate
//    
    
//    - (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
//    
//    {
//        
//        return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//        
//    }
//    
//    
//    
//    - (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//    
//    {
//        
//        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//            
//            //if ([trustedHosts containsObject:challenge.protectionSpace.host])
//            
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//        
//        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//        
//    }
    
    
    //////////////////////
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:loginURL]];
//    
//    //set HTTP Method
//    [request setHTTPMethod:@"POST"];
//    
//    //Implement request_body for send request here username and password set into the body.
//    NSString *request_body = [NSString stringWithFormat:@"Username=%@&Password=%@",[Username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [Password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    //set request body into HTTPBody.
//    [request setHTTPBody:[request_body dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //set request url to the NSURLConnection
//    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    
//    
//    if(theConnection) //get the response and retain it

    //end gclee
    
    //Create Stock Panel with header
//    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TestHeader" owner:nil options:nil][0];
//    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Welcome to MYBlurIntroductionView" description:@"MYBlurIntroductionView is a powerful platform for building app introductions and tutorials. Built on the MYIntroductionView core, this revamped version has been reengineered for beauty and greater developer control." image:[UIImage imageNamed:@"HeaderImage.png"] header:headerView];
    
    //Create Stock Panel With Image
//    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Automated Stock Panels" description:@"Need a quick-and-dirty solution for your app introduction? MYBlurIntroductionView comes with customizable stock panels that make writing an introduction a walk in the park. Stock panels come with optional blurring (iOS 7) and background image. A full panel is just one method away!" image:[UIImage imageNamed:@"ForkImage.png"]];
//
//    //Create Stock Panel With Image
//    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Automated Stock Panels" description:@"Need a quick-and-dirty solution for your app introduction? MYBlurIntroductionView comes with customizable stock panels that make writing an introduction a walk in the park. Stock panels come with optional blurring (iOS 7) and background image. A full panel is just one method away!" image:[UIImage imageNamed:@"ForkImage.png"]];
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"" description:@"" image:nil];
    
    //Create Stock Panel With Image
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"" description:@"" image:nil];
    
    //Create Panel From Nib
//    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"TestPanel3"];
    
    //Create custom panel with events
//    MYCustomPanel *panel4 = [[MYCustomPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"MYCustomPanel"];
    
    //Add panels to an array
    //NSArray *panels = @[panel1, panel2, panel3, panel4];
    NSArray *panels = @[panel1, panel2];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"tuto_test01.png"];
    
    CGSize imageSize = introductionView.BackgroundImageView.image.size;
    
    NSLog(@"***** image size per device width:%f height:%f ", imageSize.width, imageSize.height);
    NSLog(@"***** screen size per device width:%f height:%f ", kScreenBoundsWidth, kScreenBoundsHeight);
    
    
    //[UIImage imageNamed:@"bg_loading.png"]];
    
//    [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate 

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %ld", (long)panelIndex);
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    if (panelIndex == 0) {
        introductionView.BackgroundImageView.image = [UIImage imageNamed:@"tuto_test01.png"];
//        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 1){
        introductionView.BackgroundImageView.image = [UIImage imageNamed:@"tuto_test02.png"];
//        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
    }
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    
    if(self.delegate){
        
        if ([self.delegate respondsToSelector:@selector(didFinishIntro)]) {
            [self.delegate didFinishIntro];
        }
        
    }
}

@end
