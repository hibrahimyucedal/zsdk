//
//  Cause.h
//  zsdk
//
//  Created by Luis on 1/14/20.
//

typedef NS_ENUM(NSUInteger, Cause) {
    PARTIAL_FORMAT_IN_PROGRESS = 0,
    HEAD_COLD = 1,
    HEAD_OPEN = 2,
    HEAD_TOOHOT = 3,
    PAPER_OUT = 4,
    RIBBON_OUT = 5,
    RECEIVE_BUFFER_FULL = 6,
    UNKNOWN_CAUSE = 7,
};
