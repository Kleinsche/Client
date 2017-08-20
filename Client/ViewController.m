//
//  ViewController.m
//  Client
//
//  Created by Kleinsche on 2017/7/8.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

#import "ViewController.h"
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *showText;
@property (strong, nonatomic) IBOutlet UITextField *sendText;

@property (nonatomic,assign) int iService_socket;

@end

@implementation ViewController


- (IBAction)sendText:(UIButton *)sender {
    NSString *strInput = self.sendText.text;
    char *buf[1024] = {0};
    char *p1 = (char*)buf;
    p1 = [strInput cStringUsingEncoding:NSUTF8StringEncoding];
    send(self.iService_socket, p1, 1024, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int service_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (service_socket == -1) {
        NSLog(@"创建socket失败");
    } else {
        //配置地址和端口号
        struct sockaddr_in server_addr;
        server_addr.sin_len = sizeof(struct sockaddr_in);
        server_addr.sin_family = AF_INET;
        server_addr.sin_port = htons(1234);
        server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
        bzero(&(server_addr.sin_zero), 8);
        
        dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue1, ^{
            
            int a = connect(service_socket, (struct sockaddr*)&server_addr, sizeof(server_addr));
            if (a == 0) {
                self.iService_socket = service_socket;
                
                while (true) {
                    char recv_mssage[1024];
                    long byte_num = recv(service_socket, recv_mssage, 1024, 0);
                    if (byte_num > 0) {
                        //显示信息
                        NSString *string = [NSString stringWithUTF8String:recv_mssage];
                        
                        [NSOperationQueue.mainQueue addOperationWithBlock:^{
                            self.showText.text = string;
                        }];
                        
                    }
//                    else if (byte_num == -1){
//                        break;
//                    }
                    
                }
            }
            
        });
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
