#import "DDLog.h"

// Third party frameworks and libraries should define their own custom log definitions.
// These should use a custom context to allow those who use the framework
// the ability to maintain fine grained control of their logging experience.
// The logging context can be extracted from the DDLogMessage from within the logging framework,
// which gives loggers, formatters, and filters the ability to optionally process them differently.

#define END_USER_LOG_CONTEXT 1000

// Setup the usual boolean macros.
#define END_USER_LOG_ERROR   (endUserLogLevel & LOG_FLAG_ERROR)
#define END_USER_LOG_WARN    (endUserLogLevel & LOG_FLAG_WARN)
#define END_USER_LOG_INFO    (endUserLogLevel & LOG_FLAG_INFO)
#define END_USER_LOG_VERBOSE (endUserLogLevel & LOG_FLAG_VERBOSE)

// Define logging primitives.
#define EndUserLogError(frmt, ...)    SYNC_LOG_OBJC_MAYBE(endUserLogLevel, LOG_FLAG_ERROR,   END_USER_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define EndUserLogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(endUserLogLevel, LOG_FLAG_WARN,    END_USER_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define EndUserLogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(endUserLogLevel, LOG_FLAG_INFO,    END_USER_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define EndUserLogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(endUserLogLevel, LOG_FLAG_VERBOSE, END_USER_LOG_CONTEXT, frmt, ##__VA_ARGS__)
