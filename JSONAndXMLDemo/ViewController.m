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
#import "KeevinsDowloader.h"

NSString *const kUsername = @"beyond2021";

@interface ViewController ()

@property (nonatomic, strong) NSArray *arrCountries;// container for the countries

@property (nonatomic, strong) NSArray *arrCountryCodes;// container for the country codes

@property (nonatomic, strong) NSString *countryCode;// container for a country code

@property (nonatomic, strong) NSDictionary *countryDetailsDictionary;

-(void)getCountryInfo;
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
    //the path of the countries
    
    
    NSString *pathOfCountryCodesFile = [[NSBundle mainBundle] pathForResource:@"countries_short" ofType:@"txt"];
    //the path of the country codes
    
    
    NSString *allCountries = [NSString stringWithContentsOfFile:pathOfCountriesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountries = [[NSArray alloc] initWithArray:[allCountries componentsSeparatedByString:@"\n"]];
    //filling the countries container
    
    
    
    NSString *allCountryCodes = [NSString stringWithContentsOfFile:pathOfCountryCodesFile encoding:NSUTF8StringEncoding error:nil];
    self.arrCountryCodes = [[NSArray alloc] initWithArray:[allCountryCodes componentsSeparatedByString:@"\n"]];
    //filling the country code container
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
        
        [self getCountryInfo];
    }
    else{
        // If the country was not found then show an alert view displaying a relevant message.
        [[[UIAlertView alloc] initWithTitle:@"Country Not Found" message:@"The country you typed in was not found." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil] show];
    }
    
    // Hide the keyboard.
    [self.txtCountry resignFirstResponder];
    
    return YES;
}

#pragma mark - getting the data

-(void)getCountryInfo{
    // Prepare the URL that we'll get the country info data from.
    NSString *URLString = [NSString stringWithFormat:@"http://api.geonames.org/countryInfoJSON?username=%@&country=%@", kUsername, self.countryCode];
    NSURL *url = [NSURL URLWithString:URLString];
    
    
    /*
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Check if any data returned.
        if (data != nil) {
            
        }
    }];
     */
    
    [KeevinsDowloader downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Check if any data returned.
        if (data != nil) {
            //Notice that is always necessary to check if the returned data is other than nil. In case of error, no data will exist and the data object will be nil, so be careful.
            /*
             For first time, we are about to use the NSJSONSerialization class in order to convert the fetched JSON data into a Foundation object, so we can handle it. Usually, a JSON converted object matches either to a NSArray object, or to a NSDictionary object. In the most cases you can know and tell what object the JSON will be converted to, as in almost every app you can find out the form of the JSON data you’ll fetch. In the rare cases you don’t know how the JSON data is formed and what Foundation object to expect after the conversion, see right next how to determine this.
             */
            
             NSError *error;
           NSLog(@"%@", [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] class]);
            
            
            //First, we’ll convert the returned JSON data into a NSDictionary object
            //Initially, we convert the JSON data to the returnedDict dictionary.
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            //Then, we will check if any error has occurred during conversion,
            if (error != nil) {
                //
                NSLog(@"%@", [error localizedDescription]);
            }
            else{
                //and if not we’ll extract the array from that dictionary using the key geonames. Finally, we’ll extract the second, desired dictionary from the first index of that array
                //Next, we get the array and the dictionary of the first index of that array, and we assign it to the countryDetailsDictionary property.
                self.countryDetailsDictionary = [[returnedDict objectForKey:@"geonames"] objectAtIndex:0];
                NSLog(@"%@", self.countryDetailsDictionary);
                
                // Set the country name to the respective label.
                self.lblCountry.text = [NSString stringWithFormat:@"%@ (%@)", [self.countryDetailsDictionary objectForKey:@"countryName"], [self.countryDetailsDictionary objectForKey:@"countryCode"]];
                
               //Add the next two lines as well, in order to reload the data in the table view and make it appear (initially the table view is hidden):
                
                // Reload the table view.
                [self.tblCountryDetails reloadData];
                
                // Show the table view.
                self.tblCountryDetails.hidden = NO;
            }
            
            
            
        }
    }];

    
    
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
  }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  //  return 0;
    /*
     We want 7 rows to exist in our table view. We’ll use the first six rows to display the data I mentioned above, and in the last row we’ll have a cell that will let us get navigated into a new view controller, where we’ll get the neighbour countries of the selected one.
     */
    
    return 7;

    
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = @"Capital";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"capital"];
            break;
        case 1:
            cell.detailTextLabel.text = @"Continent";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"continentName"];
            break;
        case 2:
            cell.detailTextLabel.text = @"Population";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"population"];
            break;
        case 3:
            cell.detailTextLabel.text = @"Area in Square Km";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"areaInSqKm"];
            break;
        case 4:
            cell.detailTextLabel.text = @"Currency";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"currencyCode"];
            break;
        case 5:
            cell.detailTextLabel.text = @"Languages";
            cell.textLabel.text = [self.countryDetailsDictionary objectForKey:@"languages"];
            break;
        case 6:
            cell.textLabel.text = @"Neighbour Countries";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            //Pay special attention to the this last case, where we add the cell that will take us to the neighbour countries list. For this cell only, we set the disclosure indicator as the accessory type and the default selection style. That’s because we want it to prompt us to tap it, and to be highlighted when is tapped.
            
            break;
            
        default:
            break;
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
