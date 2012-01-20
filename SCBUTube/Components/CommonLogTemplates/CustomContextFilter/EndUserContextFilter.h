#import <Foundation/Foundation.h>
#import "DDLog.h"


@interface EndUserContextFilter : NSObject <DDLogFormatter>
{
}
-(NSString*) logsDirectory;
-(NSString *) logFileNameWithoutPath;

@end
