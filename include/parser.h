#import <Foundation/Foundation.h>

#import <lexer.h>
#import <nodes.h>

NSMutableArray<Node*>* parse(NSMutableArray<Token*>*);
Node* parseList(NSMutableArray<Token*>*, NSUInteger*);
Node* parseIdentifier(NSMutableArray<Token*>*, NSUInteger*);
Node* parseNumber(NSMutableArray<Token*>*, NSUInteger*);
Node* parseString(NSMutableArray<Token*>*, NSUInteger*);
