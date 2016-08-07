//
//  JPPlayground.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPPlayground.h"
#import "JPKeyCommands.h"
#import "JPCleaner.h"
#import "JPErrorView.h"
#import "JPDevMenu.h"

@interface JPPlayground ()<UIActionSheetDelegate>

@property (nonatomic,strong) NSString *rootPath;

@property (nonatomic,strong) JPKeyCommands *keyManager;

@property (nonatomic,strong) UIView *errorView;

@property (nonatomic,strong) JPDevMenu *devMenu;

@end

static void (^_reloadCompleteHandler)(void) = ^void(void) {
   
};

@implementation JPPlayground

+ (instancetype)sharedInstance
{
    static JPPlayground *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _keyManager = [JPKeyCommands sharedInstance];
        _devMenu = [[JPDevMenu alloc]init];
    }
    return self;
}

+(void)setReloadCompleteHandler:(void (^)())complete
{
    _reloadCompleteHandler = [complete copy];
}

+(void)startPlaygroundWithJSPath:(NSString *)path
{
    [[JPPlayground sharedInstance] startPlaygroundWithJSPath:path];
}

-(void)startPlaygroundWithJSPath:(NSString *)path
{
    self.rootPath = path;
    
    [JPEngine handleException:^(NSString *msg) {
        JPErrorView *errV = [[JPErrorView alloc]initError:msg];
        [[UIApplication sharedApplication].keyWindow addSubview:errV];
        self.errorView = errV;
        [self.devMenu toggle];
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        [self.devMenu toggle];
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"r" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        [self reload];
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"s" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"f" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        [self openInFinder];
    }];
}

+(void)reload
{
    [[JPPlayground sharedInstance]reload];
}

-(void)reload
{
    [self hideErrorView];
    [JPCleaner cleanAll];
    NSString *script = [NSString stringWithContentsOfFile:self.rootPath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
    _reloadCompleteHandler();
    
}

-(void)openInFinder
{
    NSURL *fileUrl = [[NSURL alloc]initFileURLWithPath:self.rootPath];
    [[UIApplication sharedApplication]openURL:fileUrl];
}

-(void)hideErrorView
{
    [self.errorView removeFromSuperview];
    self.errorView = nil;
}

@end
