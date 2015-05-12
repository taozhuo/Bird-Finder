NSString* const kEbirdUrlRecentObserv = @"http://ebird.org/ws1.1/data/obs/geo/recent?lng=%f&lat=%f&dist=%d&back=%d&maxResults=10000&locale=en_US&fmt=json&hotspot=true";

NSString* const kEbirdUrlObservationsOfASpecies = @"http://ebird.org/ws1.1/data/nearest/geo_spp/recent?lng=%f1&lat=%f&sci=%@&hotspot=true&back=%d&maxResults=500&locale=en_US&fmt=json&includeProvisional=true";

NSString* const kFlickrSearchURl = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0a29aa6f6089fd1b4917747511bdbb6d&tags=%@&format=json&nojsoncallback=1";

NSString* const kFlickrSinglePicThumbNailUrl = @"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg";
NSString* const kFlickrSinglePicBigUrl = @"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg";
NSString* const kEbirdHotspots = @"http://ebird.org/ws1.1/ref/hotspot/geo?lng=%f&lat=%f&dist=%d&back=%d&fmt=json";

NSString* const kWikiUrl = @"http://en.wikipedia.org/wiki/%@";

NSString* const kFreeBaseUrlQuery = @"https://www.googleapis.com/freebase/v1/search?query=%@&key=AIzaSyAO4soA342xcDc-Sb-QoU2_DMT19HMXtOc";

NSString* const kFreeBaseUrlDescription = @"https://www.googleapis.com/freebase/v1/topic%@?filter=/common/topic/description&key=AIzaSyAO4soA342xcDc-Sb-QoU2_DMT19HMXtOc";

NSString* const kEbirdURLNotableObserv = @"http://ebird.org/ws1.1/data/notable/geo/recent?lng=%f&lat=%f&dist=50&back=14&maxResults=100&detail=simple&locale=en_US&fmt=json";

NSString* const kEBirdURLObsOfASpecies=@"http://ebird.org/ws1.1/data/obs/geo_spp/recent?lng=%f&lat=%f&sci=%@&dist=50&back=14&hotspot=true&maxResults=500&locale=en_US&fmt=json";

NSString* const kEbirdURLObsAtHotspot=@"http://ebird.org/ws1.1/data/obs/hotspot/recent?r=%@&back=30&maxResults=10000&detail=simple&locale=en_US&fmt=json&includeProvisional=true";

NSString* const kWikiURLExtract=@"https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@";

NSString* const kFlickrWebPageURL=@"https://www.flickr.com/photos/%@/%@";

NSString* const kFlickrOwnerInfo=@"https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=0a29aa6f6089fd1b4917747511bdbb6d&user_id=%@&format=json&nojsoncallback=1";

NSString* const kEbirdObsSpAtHotspot=@"http://ebird.org/ws1.1/data/obs/hotspot_spp/recent?%@sci=%@&back=30&maxResults=10000&detail=simple&locale=en_US&fmt=json";


