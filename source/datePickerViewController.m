//
//  datePickerViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 22..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "datePickerViewController.h"


@interface datePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPickerMe;
@property (weak, nonatomic) IBOutlet UILabel *dayLable;

@end

@implementation datePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_dataPickerMe addTarget:self
               action:@selector(datePickerValueChanged:)
     forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)okClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchPicker)]) {
        [self.delegate didTouchPicker];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)datePickerValueChanged:(id)sender{
    
    UIDatePicker *picker = (UIDatePicker *)sender;
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateStyle = NSDateFormatterMediumStyle;
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *date = [dateFormat stringFromDate:picker.date];
    NSLog(@"date is >>> , %@",date);
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]]);
    
    [_dayLable setText:date];
    
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kYYYYMMDD];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
