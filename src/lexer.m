#import <lexer.h>

BOOL isidentifier(unichar c) {
  return isalnum(c) || c == '+' || c == '-' || c == '*' || c == '/' || c == '@' || c == '#' || c == '$' || c == '%' || c == '^' || c == '&' || c == '_' || c == '=' || c == '<' || c == '>' || c == '?' || c == '~' || c == '!';
}

@implementation Token 
-(id)init: (TokenType)type value: (NSString*)value {
  if (self = [super init]) {
    self->type = type;
    self->value = value;
  }
  return self;
}

+(instancetype)initIdentifier: (NSString*)source index: (NSUInteger*)index {
  NSUInteger length = 0;
  unichar c = [source characterAtIndex: *index];
  while (isidentifier(c))
    c = [source characterAtIndex: *index + (++length)];

  NSString* value = [[NSString alloc] initWithBytes: (source.UTF8String + *index) length: length encoding: NSUTF8StringEncoding];
  *index += length;
  return [[self alloc] init: TOKEN_IDENTIFIER value: value];
}

+(instancetype)initNumber: (NSString*)source index: (NSUInteger*)index {
  NSUInteger length = 0;
  unichar c = [source characterAtIndex: *index];
  while (isdigit(c) || c == '.')
    c = [source characterAtIndex: *index + (++length)];

  NSString* value = [[NSString alloc] initWithBytes: (source.UTF8String + *index) length: length encoding: NSUTF8StringEncoding];
  *index += length;
  return [[self alloc] init: TOKEN_NUMBER value: value];
}

+(instancetype)initString: (NSString*)source index: (NSUInteger*)index {
  NSUInteger length = 0;
  (*index)++;
  unichar c = [source characterAtIndex: *index];

  while (c != '"') length++;

  NSString* value = [[NSString alloc] initWithBytes: (source.UTF8String + *index) length: length encoding: NSUTF8StringEncoding];
  *index += length + 1;
  return [[self alloc] init: TOKEN_STRING value: value];
}

+(instancetype)initSymbol: (unichar)character {
  switch (character) {
    case '(': return [[self alloc] init: TOKEN_LPAREN value: @"("];
    case ')': return [[self alloc] init: TOKEN_RPAREN value: @")"];
    case '\'': return [[self alloc] init: TOKEN_QUOTE value: @"'"];
    default: NSLog(@"Called [Token initSymbol:] with invalid character"); abort(); return nil;
  }
}
@end

NSMutableArray<Token*>* lex(NSString* source) {
  NSMutableArray<Token*>* tokens = [[NSMutableArray alloc] init];

  NSUInteger index = 0;
  while (index < [source length]) {
    while (isspace([source characterAtIndex: index])) index++;

    unichar c = [source characterAtIndex: index];

    if (!isdigit(c) && isidentifier(c)) {
      [tokens addObject: [Token initIdentifier: source index: &index]];
    } else if (isdigit(c)) {
      [tokens addObject: [Token initNumber: source index: &index]];
    } else if (c == '(' || c == ')' || c == '\'') {
      [tokens addObject: [Token initSymbol: c]];
      index++;
    } else if (c == '"') {
      [tokens addObject: [Token initString: source index: &index]];
    } else {
      NSLog(@"Unrecognised token: %c", c);
    }
  }

  return tokens;
}
