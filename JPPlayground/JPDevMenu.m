//
//  JPPlaygroundMenu.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPDevMenu.h"
#import <UIKit/UIKit.h>

@interface JPDevMenuItem : NSObject

/**
 * This creates an item with a simple push-button interface, used to trigger an
 * action.
 */
+ (instancetype)buttonItemWithTitle:(NSString *)title
                            handler:(void(^)(void))handler;

/**
 * This creates an item with a toggle behavior. The key is used to store the
 * state of the toggle. For toggle items, the handler will be called immediately
 * after the item is added if the item was already selected when the module was
 * last loaded.
 */
+ (instancetype)toggleItemWithKey:(NSString *)key
                            title:(NSString *)title
                    selectedTitle:(NSString *)selectedTitle
                          handler:(void(^)(BOOL selected))handler;
@end

typedef NS_ENUM(NSInteger, JPDevMenuType) {
    JPDevMenuTypeButton,
    JPDevMenuTypeToggle
};

@interface JPDevMenuItem ()

@property (nonatomic, assign, readonly) JPDevMenuType type;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *selectedTitle;
@property (nonatomic, copy) id value;

@end

@implementation JPDevMenuItem
{
    id _handler; // block
}

- (instancetype)initWithType:(JPDevMenuType)type
                         key:(NSString *)key
                       title:(NSString *)title
               selectedTitle:(NSString *)selectedTitle
                     handler:(id /* block */)handler
{
    if ((self = [super init])) {
        _type = type;
        _key = [key copy];
        _title = [title copy];
        _selectedTitle = [selectedTitle copy];
        _handler = [handler copy];
        _value = nil;
    }
    return self;
}

+ (instancetype)buttonItemWithTitle:(NSString *)title
                            handler:(void (^)(void))handler
{
    return [[self alloc] initWithType:JPDevMenuTypeButton
                                  key:nil
                                title:title
                        selectedTitle:nil
                              handler:handler];
}

+ (instancetype)toggleItemWithKey:(NSString *)key
                            title:(NSString *)title
                    selectedTitle:(NSString *)selectedTitle
                          handler:(void (^)(BOOL selected))handler
{
    return [[self alloc] initWithType:JPDevMenuTypeToggle
                                  key:key
                                title:title
                        selectedTitle:selectedTitle
                              handler:handler];
}

- (void)callHandler
{
    switch (_type) {
        case JPDevMenuTypeButton: {
            if (_handler) {
                ((void(^)())_handler)();
            }
            break;
        }
        case JPDevMenuTypeToggle: {
            if (_handler) {
                ((void(^)(BOOL selected))_handler)([_value boolValue]);
            }
            break;
        }
    }
}

@end

@interface JPDevMenu ()<UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet * actionSheet;
@property (nonatomic,strong) NSArray<JPDevMenuItem *> *presentedItems;

@end

@implementation JPDevMenu


- (NSArray<JPDevMenuItem *> *)menuItems
{
    NSMutableArray<JPDevMenuItem *> *items = [NSMutableArray new];
    
    // Add built-in items
    
    
    [items addObject:[JPDevMenuItem buttonItemWithTitle:@"Reload Command+R" handler:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:)]) {
            [self.delegate devMenuDidAction:JPDevMenuActionReload];
        }
    }]];
    
    [items addObject:[JPDevMenuItem buttonItemWithTitle:@"Hide ErrorView Command+H" handler:^{
//        [self hideErrorView];
    }]];
    
    [items addObject:[JPDevMenuItem buttonItemWithTitle:@"Show JS in Finder Command+F" handler:^{
//        [self openInFinder];
    }]];
    
    
    return items;
}


- (void)toggle
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    } else {
        [self show];
    }
    
}

-(void)show
{
    
    if (_actionSheet ) {
        [_actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        return;
    }
    
    UIActionSheet *actionSheet = [UIActionSheet new];
    actionSheet.title = @"JPatch Playgournd : Command + x";
    actionSheet.delegate = self;
    
    NSArray<JPDevMenuItem *> *items = [self menuItems];
    for (JPDevMenuItem *item in items) {
        switch (item.type) {
            case JPDevMenuTypeButton: {
                [actionSheet addButtonWithTitle:item.title];
                break;
            }
            case JPDevMenuTypeToggle: {
                BOOL selected = [item.value boolValue];
                [actionSheet addButtonWithTitle:selected? item.selectedTitle : item.title];
                break;
            }
        }
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    //    actionSheet.actionSheetStyle = UIBarStyleBlack;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    _actionSheet = actionSheet;
    _presentedItems = items;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _actionSheet = nil;
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    JPDevMenuItem *item = _presentedItems[buttonIndex];
    switch (item.type) {
        case JPDevMenuTypeButton: {
            [item callHandler];
            break;
        }
        case JPDevMenuTypeToggle: {
//            BOOL value = [_settings[item.key] boolValue];
//            [self updateSetting:item.key value:@(!value)]; // will call handler
            break;
        }
    }
    return;
}


-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:)]) {
        [self.delegate devMenuDidAction:JPDevMenuActionCancel];
    }
}



@end
