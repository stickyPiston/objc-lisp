#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TokenType) {
  TOKEN_IDENTIFIER,
  TOKEN_NUMBER,
  TOKEN_LPAREN,
  TOKEN_RPAREN,
  TOKEN_STRING,
  TOKEN_QUOTE
};

@interface Token : NSObject {
  @public TokenType type;
  @public NSString* value;
}

-(id)init: (TokenType)type value: (NSString*)value;

+(instancetype)initIdentifier: (NSString*)source index: (NSUInteger*)index;
+(instancetype)initNumber: (NSString*)source index: (NSUInteger*)index;
+(instancetype)initString: (NSString*)source index: (NSUInteger*)index;
+(instancetype)initSymbol: (unichar)character;

@end

NSMutableArray<Token*>* lex(NSString* source);
