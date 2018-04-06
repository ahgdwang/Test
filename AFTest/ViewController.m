//
//  ViewController.m
//  AFTest
//
//  Created by WangYiming on 2018/4/3.
//  Copyright © 2018年 WangYiming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong,nonatomic) UIImageView *imageView;
@property(strong,nonatomic) UIProgressView *progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat width = 300;
    CGFloat height = 400;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0.5*(screen.size.width - width), 20, width, 20);
    [button setTitle:@"上传" forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x, 50, width, height)];
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    self.imageView.image = image;
    [self.view addSubview:self.imageView];
    
    self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progress.frame = CGRectMake(0.5*(screen.size.width - 500), 600, 500, 50);
    [self.view addSubview:self.progress];
    
    
}
- (void)onClick:(id)sender{
    NSString *urlStr = @"http://www.51work6.com/service/upload.php";
    NSDictionary *params = @{@"email":@"442494908@qq.com"};
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@".jpg"];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"path" fileName:@"1.jpg" mimeType:@"image/jpg" error:nil];
    } error:(nil)];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%@",[uploadProgress localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress setProgress:uploadProgress.fractionCompleted];
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"上传成功");
            [self down];
        }else{
            NSLog(@"%@",error.description);
        }
    }];
    [task resume];
}
- (void)down{
    NSString *downPathStr = [NSString stringWithFormat:@"http://www.51work6.com/service/download.php?email=%@&FileName=1.jpg",@"442494908@qq.com"];
    NSURL *downURL = [NSURL URLWithString:downPathStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:downURL];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *task2 = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@",[downloadProgress localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress setProgress:downloadProgress.fractionCompleted];
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *savepath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imagePath = [savepath stringByAppendingPathComponent:[response suggestedFilename]];
        NSURL *imagePathURL = [NSURL fileURLWithPath:imagePath];
        NSLog(@"%@",targetPath);
        return imagePathURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",filePath);
        NSData *data = [NSData dataWithContentsOfURL:filePath];
        UIImage *image = [UIImage imageWithData:data];
        self.imageView.image = image;
        int i =1;
    }];
    [task2 resume];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
