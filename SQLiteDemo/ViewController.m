//
//  ViewController.m
//  SQLiteDemo
//
//  Created by highcom on 15-2-5.
//  Copyright (c) 2015年 zhanglei. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.status = @"";
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    // Do any additional setup after loading the view, typically from a nib.
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    [topView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:topView];
    
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 40)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setText:@"SQLite测试"];
    [self.view addSubview:title];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 60, [UIScreen mainScreen].bounds.size.width-40, 30)];
    [label setText:@"请输入信息:"];
    [label setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:label];
    
    UILabel * nameTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 90, 50, 40)];
    [nameTitle setText:@"姓名:"];
    [self.view addSubview:nameTitle];
    
    self.name = [[UITextField alloc] initWithFrame:CGRectMake(90, 94, 150, 30)];
    [self.name setBackgroundColor:[UIColor whiteColor]];
    [self.name.layer setMasksToBounds:YES];
    [self.name.layer setCornerRadius:4];
    self.name.delegate = self;
    [self.view addSubview:self.name];
    
    UILabel * phoneTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 130, 50, 40)];
    [phoneTitle setText:@"电话:"];
    [self.view addSubview:phoneTitle];
    
    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(90, 134, 150, 30)];
    [self.phone setBackgroundColor:[UIColor whiteColor]];
    [self.phone.layer setMasksToBounds:YES];
    [self.phone.layer setCornerRadius:4];
    self.phone.delegate = self;
    [self.view addSubview:self.phone];
    
    UILabel * addrTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 170, 50, 40)];
    [addrTitle setText:@"地址:"];
    [self.view addSubview:addrTitle];
    
    self.addr = [[UITextField alloc] initWithFrame:CGRectMake(90, 174, 150, 30)];
    [self.addr setBackgroundColor:[UIColor whiteColor]];
    [self.addr.layer setMasksToBounds:YES];
    [self.addr.layer setCornerRadius:4];
    self.addr.delegate = self;
    [self.view addSubview:self.addr];
    
    
    UIButton * btnSave = [[UIButton alloc] initWithFrame:CGRectMake(40, 220, 100,40)];
    [btnSave setTitle:@"存储" forState:UIControlStateNormal];
    [btnSave setBackgroundColor:[UIColor blackColor]];
    [btnSave addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];
    
    UIButton * btnRead = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-40-100, 220, 100,40)];
    [btnRead setTitle:@"读取" forState:UIControlStateNormal];
    [btnRead setBackgroundColor:[UIColor blackColor]];
    [btnRead addTarget:self action:@selector(read) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRead];
    
    [self initAndCreate];
    
    
}
//初始化并且创建数据库
-(void)initAndCreate{
    
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"info.db"]];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //检验是否数据库已存在，存在跳过 不存在创建
    if ([filemanager fileExistsAtPath:self.databasePath] == NO) {
        const char *dbpath = [self.databasePath UTF8String];
        if (sqlite3_open(dbpath, &db)==SQLITE_OK) {
            char *errmsg;
            const char *createsql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, NUM TEXT, CLASSNAME TEXT,NAME TEXT)";
            if (sqlite3_exec(db, createsql, NULL, NULL, &errmsg)!=SQLITE_OK) {
                self.status = @"create table failed.";
            }
        }
        else {
            self.status = @"create/open failed.";
        }
    }
    NSLog(@"%@",self.status);
}

-(void)save{
    
    sqlite3_stmt *statement;
    
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &db)==SQLITE_OK) {
        if ([self.name.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SORRY!" message:@"number cannot be nil!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO INFO (num,classname,name) VALUES(\"%@\",\"%@\",\"%@\")",self.name.text,self.phone.text,self.addr.text];
            const char *insertstaement = [insertSql UTF8String];
            sqlite3_prepare_v2(db, insertstaement, -1, &statement, NULL);
            if (sqlite3_step(statement)==SQLITE_DONE) {
                self.status = @"save to DB.";
                self.name.text = @"";
                self.phone.text = @"";
                self.addr.text = @"";
            }
            else {
                self.status = @"save failed!";
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }  
    }
}

-(void)read{
    const char *dbpath = [self.databasePath UTF8String];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &db)==SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT classname,name from info where num=\"%@\"",self.name.text];
        const char *querystatement = [querySQL UTF8String];
        if (sqlite3_prepare_v2(db, querystatement, -1, &statement, NULL)==SQLITE_OK) {
            if (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *classnameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                self.phone.text = classnameField;
                NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                self.addr.text = nameField;
                
                self.status = @"find~~~";
            }
            else {
                self.status = @"did not find you need.";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
