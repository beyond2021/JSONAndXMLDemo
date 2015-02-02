//
//  ViewController.m
//  JSONAndXMLDemo
//
//  Created by Gabriel Theodoropoulos on 24/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "NeighboursViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSArray *arrCountries;

@property (nonatomic, strong) NSArray *arrCountryCodes;

@property (nonatomic, strong) NSString *countryCode;

@property (nonatomic, strong) NSDictionary *countryDetailsDictionary;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Make self the delegate of the textfield.
    self.txtCountry.delegate = self;
    
    // Make self the delegate and datasource of the table view.
    self.tblCountryDetails.delegate = self;
    self.tblCountryDetails.dataSource = self;
    
    // Initially hide the table view.
    self.tblCountryDetails.hidden = YES;
    
    
    // Load the contents of the two .txt files to the arrays.
    NSString *pathOfCountriesFile = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"txt"];
    NSString *pathOfCountryCodesFile = [[NSBundle mainBundle] pathForResource:@"countries_short" ofType:@"txt"];
    
    NSString *allCountries = [NSString stringWithContentsOfFile:pathOfCountriesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountries = [[NSArray alloc] initWithArray:[allCountries componentsSeparatedByString:@"\n"]];
    
    NSString *allCountryCodes = [NSString stringWithContentsOfFile:pathOfCountryCodesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountryCodes = [[NSArray alloc] initWithArray:[allCountryCodes componentsSeparatedByString:@"\n"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // Find the index of the typed country in the arrCountries array.
    NSInteger index = -1;
    for (NSUInteger i=0; i<self.arrCountries.count; i++) {
        NSString *currentCountry = [self.arrCountries objectAtIndex:i];
        if ([currentCountry rangeOfString:self.txtCountry.text.uppercaseString].location != NSNotFound) {
            index = i;
            break;
        }
    }
    
    // Check if the given country was found.
    if (index != -1) {
        // Get the two-letter country code from the arrCountryCodes array.
        self.countryCode = [self.arrCountryCodes objectAtIndex:index];
    }
    else{
        // If the country was not found then show an alert view displaying a relevant message.
        [[[UIAlertView alloc] initWithTitle:@"Country Not Found" message:@"The country you typed in was not found." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil] show];
    }
    
    // Hide the keyboard.
    [self.txtCountry resignFirstResponder];
    
    return YES;
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 6) {
        [self performSegueWithIdentifier:@"idSegueNeighbours" sender:self];
    }
}


#pragma mark - IBAction method implementation

- (IBAction)sendJSON:(id)sender {
    
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
