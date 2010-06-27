//
//  UIPartsMacro.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/01/05.
//  Copyright 2010 EY-Office. All rights reserved.
//
#import <Foundation/Foundation.h>


#define LENGTH_OF(a)	(sizeof(a) / sizeof(a[0]))

#define addCellToTextField(name) {\
	UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(120, 12, 180, 24)] autorelease];\
	textField.delegate = self;\
	textField.clearButtonMode = UITextFieldViewModeAlways;\
	textField.textColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.5 alpha:1.0];\
	self.name = textField;\
	[cell addSubview:name];\
	}

#define addCellToFullTextField(name) {\
	UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(20, 12, 280, 24)] autorelease];\
	textField.delegate = self;\
	textField.clearButtonMode = UITextFieldViewModeAlways;\
	textField.textColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.5 alpha:1.0];\
	self.name = textField;\
	[cell addSubview:name];\
}

