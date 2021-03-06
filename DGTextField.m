//
//  DGTextField.m
//  DGTextField
//
//  Created by Daniel Cohen Gindi on 10/19/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/DGTextField
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import "DGTextField.h"

@interface DGTextField ()
{
    BOOL _bypassClearButtonRect;
    BOOL _hasSemanticDirection;
}
@end

@implementation DGTextField

- (void)initialize_DGTextField
{
    self.textDirection = UITextWritingDirectionNatural;
    _hasSemanticDirection = ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize_DGTextField];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize_DGTextField];
    }
    return self;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    //[self setNeedsDisplay]; // this doesn't refresh placeholder color
    NSString *placeholder = self.placeholder;
    self.placeholder = @"";
    self.placeholder = placeholder;
}

- (void)setClearButtonInsets:(UIEdgeInsets)clearButtonInsets
{
    _clearButtonInsets = clearButtonInsets;
    [self setNeedsDisplay];
}

- (void)setTextDirection:(UITextDirection)textDirection
{
    _textDirection = textDirection;
    [self setNeedsDisplay];
}

#pragma mark - UITextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (_placeholderColor)
    {
        [_placeholderColor setFill];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = self.textAlignment;
        
        NSDictionary *drawAttrs = @{NSFontAttributeName: self.font,
                                    NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: _placeholderColor};
        
        CGSize size = [self.placeholder sizeWithAttributes:drawAttrs];
        rect.origin.y += (rect.size.height - size.height) / 2.f;
        [self.placeholder drawInRect:rect withAttributes:drawAttrs];
    }
    else
    {
        [super drawPlaceholderInRect:rect];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    BOOL isRtl = [[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft;
    BOOL isAlreadyFlipped = _hasSemanticDirection && [UITextField userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
    
    if (((isRtl && _textDirection == UITextWritingDirectionNatural)
        || _textDirection == UITextWritingDirectionRightToLeft) != isAlreadyFlipped)
    {
        _bypassClearButtonRect = YES;
        CGRect rect = UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _contentInsets);
        _bypassClearButtonRect = NO;
        rect.origin.x = bounds.origin.x + bounds.size.width - rect.size.width - (rect.origin.x - bounds.origin.x);
        return rect;
    }
    else
    {
        return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _contentInsets);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
	CGRect rect = [super clearButtonRectForBounds:bounds];
    if (!_bypassClearButtonRect)
    {
        BOOL isRtl = [[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft;
        BOOL isAlreadyFlipped = _hasSemanticDirection && [UITextField userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
        
        if (isAlreadyFlipped)
        {
            rect.origin.x -= _clearButtonInsets.right - _clearButtonInsets.left;
            rect.origin.y -= _clearButtonInsets.top - _clearButtonInsets.bottom;
        }
        else
        {
            rect.origin.x += _clearButtonInsets.right - _clearButtonInsets.left;
            rect.origin.y += _clearButtonInsets.top - _clearButtonInsets.bottom;
        }
        
        if (((isRtl && _textDirection == UITextWritingDirectionNatural)
            || _textDirection == UITextWritingDirectionRightToLeft) != isAlreadyFlipped)
        {
            rect.origin.x = bounds.origin.x + bounds.size.width - rect.size.width - (rect.origin.x - bounds.origin.x);
        }
    }
    return rect;
}

@end
