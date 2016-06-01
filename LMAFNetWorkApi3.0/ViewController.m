//
//  ViewController.m
//  LMAFNetWorkApi3.0
//
//  Created by wjc on 16/5/25.
//  Copyright © 2016年 Lim. All rights reserved.
//

#import "ViewController.h"
#import "LMAFNetWorkAPI.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
//  请求
//   [LMAFNetWorkAPI AFNet_GETRequest:nil appendUrl:@"http://api.beikeshushe.com/gateway.php??uid=33&method=readgroup.recommend_read_group&p=1" success:^(NSDictionary *requestDic, NSString *msg) {
//       
//       NSLog(@"the requestDic is%@  msg is%@",requestDic,msg);
//       
//   } fail:^(NSString *errorInfo) {
//       
//   } cache:YES showHUD:NO];
    
    //图片
    NSString *path=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/image.jpg"]];
    [[LMAFNetWorkAPI shareInstance] downloadWithUrl:@"http://www.aomy.com/attach/2012-09/1347583576vgC6.jpg" saveToPath:path progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        NSLog(@"the progress is%@",[NSString stringWithFormat:@"进度==%.2f",1.0 * bytesProgress/totalBytesProgress]) ;
    } success:^(NSDictionary *requestDic, NSString *msg) {
        
        
    } failure:^(NSString *errorInfo) {
        
    } showHUD:NO];
    

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
