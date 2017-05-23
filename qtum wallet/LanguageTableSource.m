//
//  LanguageTableSource.m
//  qtum wallet
//
//  Created by Sharaev Vladimir on 23.05.17.
//  Copyright © 2017 PixelPlex. All rights reserved.
//

#import "LanguageTableSource.h"
#import "LanguageTableViewCell.h"
#import "LanguageManager.h"

@interface LanguageTableSource()

@property (nonatomic, weak) LanguageTableViewCell *selectedCell;

@end

@implementation LanguageTableSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LanguageManager languageStrings].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LanguageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageTableViewCell"];
    
    BOOL selected = [LanguageManager currentLanguageIndex] == indexPath.row;
    [cell setData:[LanguageManager languageStrings][indexPath.row] selected:selected];
    
    if (selected) {
        self.selectedCell = cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LanguageTableViewCell *cell = (LanguageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isEqual:self.selectedCell]) {
        return;
    }
    
    if (self.selectedCell) {
        [self.selectedCell changeCellStyle:NO];
    }
    
    [cell changeCellStyle:YES];
    self.selectedCell = cell;
    
    [LanguageManager saveLanguageByIndex:indexPath.row];
    if ([self.delegate performSelector:@selector(languageDidChanged)]) {
        [self.delegate languageDidChanged];
    }
}

@end