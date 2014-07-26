NSString* const kEbirdUrlRecentObserv = @"http://ebird.org/ws1.1/data/obs/geo/recent?lng=%f&lat=%f&dist=50&back=30&maxResults=10000&locale=en_US&fmt=json";

NSString* const kFlickrUrl = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0a29aa6f6089fd1b4917747511bdbb6d&tags=%@&format=json&nojsoncallback=1";

NSString* const kFlickrSinglePicThumbNailUrl = @"http://farm%@.static.flickr.com/%@/%@_%@_t.jpg";
NSString* const kFlickrSinglePicBigUrl = @"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg";
NSString* const kEbirdHotspots = @"http://ebird.org/ws1.1/ref/hotspot/geo?lng=%f&lat=%f&dist=50&fmt=json";