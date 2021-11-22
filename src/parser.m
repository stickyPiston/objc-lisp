#import <lexer.h>
#import <parser.h>

NSMutableArray<Node*>* parse(NSMutableArray<Token*>* tokens) {
  NSMutableArray<Node*>* nodes = [[NSMutableArray alloc] init];
  for (NSUInteger index = 0; index < tokens.count; ) {
    Token* t = tokens[index];
    
    switch (t->type) {
      case TOKEN_LPAREN: index++; [nodes addObject: parseList(tokens, &index)]; break;
      case TOKEN_IDENTIFIER: [nodes addObject: parseIdentifier(tokens, &index)]; break;
      case TOKEN_NUMBER: [nodes addObject: parseNumber(tokens, &index)]; break;
      case TOKEN_STRING: [nodes addObject: parseString(tokens, &index)]; break;
      default: abort(); return nil;
    }
  }
  return nodes;
}

Node* parseList(NSMutableArray<Token*>* tokens, NSUInteger* index) {
  NSMutableArray<Node*>* elements = [[NSMutableArray alloc] init];
  while (![tokens[*index]->value isEqual: @")"]) {
    Node* n; BOOL quoted = NO;
    whenQuoted:
    switch (tokens[*index]->type) {
      case TOKEN_LPAREN: (*index)++; n = parseList(tokens, index); break;
      case TOKEN_IDENTIFIER: n = parseIdentifier(tokens, index); break;
      case TOKEN_NUMBER: n = parseNumber(tokens, index); break;
      case TOKEN_STRING: n = parseString(tokens, index); break;
      case TOKEN_QUOTE: { quoted = YES; (*index)++; goto whenQuoted; }
      default: abort(); return nil;
    }
    if (quoted)
      n = [[ListNode alloc] init: [[NSMutableArray alloc] initWithArray: @[[[IdentifierNode alloc] init: @"'"], n]]];
    [elements addObject: n];
  }
  (*index)++;
  return [[ListNode alloc] init: elements];
}

Node* parseIdentifier(NSMutableArray<Token*>* tokens, NSUInteger* index) {
  (*index)++;
  return [[IdentifierNode alloc] init: tokens[*index - 1]->value];
}

Node* parseNumber(NSMutableArray<Token*>* tokens, NSUInteger* index) {
  (*index)++;
  return [[NumberNode alloc] init: [tokens[*index - 1]->value floatValue]];
}

Node* parseString(NSMutableArray<Token*>* tokens, NSUInteger* index) {
  (*index)++;
  return [[StringNode alloc] init: tokens[*index - 1]->value];
}
