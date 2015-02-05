//
//  ViewController.h
//  SQLiteDemo
//
//  Created by highcom on 15-2-5.
//  Copyright (c) 2015年 zhanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
@interface ViewController : UIViewController<UITextFieldDelegate>{
    sqlite3 * db;
}

@property (nonatomic,retain) UITextField * name;
@property (nonatomic,retain) UITextField * phone;
@property (nonatomic,retain) UITextField * addr;
@property (nonatomic,retain) NSString * databasePath;
@property (nonatomic,retain) NSString * status;

@end

