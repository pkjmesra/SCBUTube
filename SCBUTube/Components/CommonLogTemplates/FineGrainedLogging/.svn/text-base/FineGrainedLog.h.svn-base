#import "DDLog.h"

// The first 4 bits are being used by the standard levels (0 - 3) 
// All other bits are fair game for us to use.

#define LOG_FLAG_AUDIO    (1 << 4)  // 0...0010000
#define LOG_FLAG_VIDEO   (1 << 5)  // 0...0100000
// AND SO ON SO FORTH
#define LOG_AUDIO  (ddLogLevel & LOG_FLAG_AUDIO)
#define LOG_VIDEO (ddLogLevel & LOG_FLAG_VIDEO)

#define DDLogAudio(frmt, ...)   ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_AUDIO,  0, frmt, ##__VA_ARGS__)
#define DDLogVideo(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_VIDEO, 0, frmt, ##__VA_ARGS__)

// Now we decide which flags we want to enable in our application

#define LOG_FLAG_ALL_COMPONENTS (LOG_FLAG_AUDIO | LOG_FLAG_VIDEO)
