//
//  NeighboursViewController.m
//  JSONAndXMLDemo
//
//  Created by Gabriel Theodoropoulos on 24/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
/*
 
 The xmlParser property is the one that we’ll use to parse the XML data.
 The arrNeighboursData property is the array that will contain all of the desired data after the parsing has finished.
 The dictTempDataStorage property is the dictionary in which we’ll temporarily store the two values we seek for each neighbour country until we add it to the array.
 The foundValue mutable string will be used to store the found characters of the elements of interest.
 The currentElement string will be assigned with the name of the element that is parsed at any moment.

 */

#import "NeighboursViewController.h"
#import "AppDelegate.h"
#import "KeevinsDowloader.h"

@interface NeighboursViewController ()

@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSMutableArray *arrNeighboursData; //the datasource of the table view is going to be the arrNeighboursData array

@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;

@property (nonatomic, strong) NSMutableString *foundValue;

@property (nonatomic, strong) NSString *currentElement;

-(void)downloadNeighbourCountries;
@end

@implementation NeighboursViewController

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
    
    
    // Make self the delegate and datasource of the table view.
    self.tblNeighbours.delegate = self;
    self.tblNeighbours.dataSource = self;
    
    // Download the neighbour countries data.
    [self downloadNeighbourCountries];
}

-(void)downloadNeighbourCountries{
    // Prepare the URL that we'll get the neighbour countries from.
    NSString *URLString = [NSString stringWithFormat:@"http://api.geonames.org/neighbours?geonameId=%@&username=%@", self.geonameID, kUsername];
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    // Download the data.
    [KeevinsDowloader downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Make sure that there is data.
        // With these four lines in the block, we initialize the parser object, we set our class as its delegate, we initialize the mutable string that we’ll use for storing the parsed values and finally we start parsing.
        if (data != nil) {
            self.xmlParser = [[NSXMLParser alloc] initWithData:data];
            self.xmlParser.delegate = self;
            
            // Initialize the mutable string that we'll use during parsing.
            self.foundValue = [[NSMutableString alloc] init];
            
            // Start parsing.
            [self.xmlParser parse];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return 0;
    return self.arrNeighboursData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // As you see, in the text label of the cell we assign the name of the country, and we set the toponym name to the subtitle label.    
    cell.textLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"toponymName"];
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark - Parser Delegate Methods
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    
    //this delegate method signals the beginning of the parsing, so we initialize our array
    //the datasource of the table view is going to be the arrNeighboursData array
    self.arrNeighboursData = [[NSMutableArray alloc] init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    // When the parsing has been finished then simply reload the table view.
    // After the parsing has finished, we simply reload the data on the table view.
    [self.tblNeighbours reloadData];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    // Nothing difficult here too, as we simply display the error description on the console
    NSLog(@"%@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    //Two things happen here: If the parser is about to start parsing the data of a new country, then we initialize the dictionary. The second is that we store the current element name (you’ll see why in the last delegate method).
    // If the current element name is equal to "geoname" then initialize the temporary dictionary.
    if ([elementName isEqualToString:@"geoname"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
    }
    
    // Keep the current element.
    self.currentElement = elementName;
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    /*
     This delegate method is called when the closing tag of an element has been parsed. If the element is equal to the “geoname” value, then we know that the data of a country was parsed, so we can add the dictionary to the array. Also, if the element is any of the two we care about, then we store the found value to the dictionary. At the end, we clear the mutable string from any contents, so it will be ready for new values to be appended to it. The last one:
     */
    
    if ([elementName isEqualToString:@"geoname"]) {
        // If the closing element equals to "geoname" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        // the datasource of the table view is going to be the arrNeighboursData array
        [self.arrNeighboursData addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
    }
    else if ([elementName isEqualToString:@"name"]){
        // If the country name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"name"];
    }
    else if ([elementName isEqualToString:@"toponymName"]){
        // If the toponym name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"toponymName"];
    }
    
    // Clear the mutable string.
    [self.foundValue setString:@""];
    /*
     
     */
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    /*
     Here you can see why the currentElement property is needed for. In case that the current element is any of the two we are interested in, then we keep the actual values found between the opening and closing tags. If you notice, you’ll see that I check for the new line string (“\n”), and if the found string is other than that, then I’m appending it to the foundValue property. That’s because after having tested the app, I noticed that a new line string was parsed before the country name, so this is just a workaround to that problem     */
    
    
    if ([self.currentElement isEqualToString:@"name"] ||
        [self.currentElement isEqualToString:@"toponymName"]) {
        
        if (![string isEqualToString:@"\n"]) {
            [self.foundValue appendString:string];
        }
    }
}

@end
