//
//  KeevinsDowloader.h
//  JSONAndXMLDemo
//
//  Created by KEEVIN MITCHELL on 2/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeevinsDowloader : NSObject

+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void(^)(NSData *data))completionHandler;// Class method for downloader. There are three noticeable things here. The first one is that we begin with the plus (+) symbol instead of the minus, as this is a class method. Next, as you can see it accepts two parameters: The first one is the URL that we’ll get the data from. The second one, is a completion handler that the method will invoke after having fetched the desired data. In order to get the data we need, we’ll use a NSURLSessionDataTask task. That class, which is a child of the NSURLSessionTask abstract class, it requires two preliminary steps before putting it in action: To instantiate a NSURLSessionConfiguration and a NSURLSession objec
@end
