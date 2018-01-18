//
//  ViewController.m
//  SHGoBelieveIMDemo
//
//  Created by angle on 2018/1/17.
//  Copyright © 2018年 angle. All rights reserved.
//

#import "ViewController.h"

#import <SHGoBelieveIM/SHGoBelieveIM.h>

#import "SHBottomInputBar.h"
#import "SHTipView.h"

@interface ViewController ()<SHIMMangerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SHBottomInputBar *inputBar;


@property (nonatomic, strong) NSMutableArray *dataArr;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self startIM];
    
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputBar];
}
#pragma mark -
#pragma mark   ==============键盘处理==============
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification{
    NSLog(@"keyboard show");
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int h = CGRectGetHeight(screenBounds);
    int w = CGRectGetWidth(screenBounds);
    
    int y = 0;
    
    CGRect tableViewFrame = CGRectMake(0.0f,  y, w,  h - self.inputBar.bounds.size.height - keyboardRect.size.height - y);
    y = h - keyboardRect.size.height;
    y -= self.inputBar.bounds.size.height;
    CGRect inputViewFrame = CGRectMake(0, y, self.inputBar.frame.size.width, self.inputBar.bounds.size.height);
    self.inputBar.frame = inputViewFrame;
    self.tableView.frame = tableViewFrame;
    [self scrollToBottomAnimated:NO];
    [UIView commitAnimations];
    
}

- (void)handleWillHideKeyboard:(NSNotification *)notification{
    NSLog(@"keyboard hide");
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect inputViewFrame = CGRectOffset(self.inputBar.frame, 0, keyboardRect.size.height);
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height += keyboardRect.size.height;
    
    self.inputBar.frame = inputViewFrame;
    self.tableView.frame = tableViewFrame;
    
    [self scrollToBottomAnimated:NO];
    [UIView commitAnimations];
}
#pragma mark -
#pragma mark   ==============启动IM==============
- (void)startIM {
    [SHIMManger sharedInstance].IMlogEnble = YES;
    
    [SHIMManger sharedInstance].delegate = self;
    
    [SHIMManger sharedInstance].uid = 1;
    [SHIMManger sharedInstance].roomID = 1001;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *token = [self login:1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",token);
            if (token) {
                [[SHIMManger sharedInstance] connectToServerWithSendToken:token];
            }
        });
    });

}
- (NSString*)login:(long long)uid {
    //调用app自身的服务器获取连接im服务必须的access token
    NSString *url = @"http://demo.gobelieve.io/auth/token";
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    
    [urlRequest setAllHTTPHeaderFields:headers];
    
    
    NSDictionary *obj = [NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:uid] forKey:@"uid"];
    NSData *postBody = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    
    [urlRequest setHTTPBody:postBody];
    
    NSURLResponse *response = nil;
    
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"error:%@", error);
        return nil;
    }
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)response;
    if (httpResp.statusCode != 200) {
        return nil;
    }
    NSDictionary *e = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return [e objectForKey:@"token"];
}
#pragma mark -
#pragma mark   ==============SHIMMangerDelegate==============
-(void)sendMessage:(SHIMManger *)im didMessage:(NSString *)msg withState:(BOOL)success {
    if (success) {
        [self.dataArr addObject:msg];
        [self deleteRedundant];
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
            [self scrollToBottomAnimated:NO];
        }];
    }else {
        [SHTipView showError:@"消息发送失败" style:SHProgressTipStyleCenter];
    }
}
-(void)receviceMessage:(SHIMManger *)im didReceiveMessage:(NSString *)msg {
    [self.dataArr addObject:msg];
    [self deleteRedundant];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
        [self scrollToBottomAnimated:NO];
    }];
}
-(void)connectSuccessIM:(SHIMManger *)im {
    self.inputBar.userInteractionEnabled = YES;
}
-(void)closeConnectIM {
    self.inputBar.userInteractionEnabled = NO;
}
//删除超屏内容
- (void)deleteRedundant {
    NSInteger count =  (NSInteger)SCREEN_HEIGHT / 30;
    
    NSInteger redundant = self.dataArr.count - count;
    if (redundant > 0) {
        [self.dataArr removeObjectsInRange:NSMakeRange(0, redundant)];
    }
    NSLog(@"%ld",self.dataArr.count);
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    if (self.dataArr.count == 0) {
        return;
    }
    long lastRow = [self.dataArr count] - 1;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
}
#pragma mark -
#pragma mark   ==============UITableViewDataSource==============
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    if (indexPath.row < self.dataArr.count) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row]];
    }
    return cell;
}
#pragma mark -
#pragma mark   ==============lazy==============
- (SHBottomInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [[SHBottomInputBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH, 49)];
        _inputBar.sendBlock = ^(NSString *content) {
            if (content && ![content isEqualToString:@""]) {
                [[SHIMManger sharedInstance] sendString:content];
            }
        };
    }
    return _inputBar;
}
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 30;
        [_tableView setTableFooterView:[UIView new]];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
