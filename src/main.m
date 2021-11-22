#import <Foundation/Foundation.h>

#import <parser.h>
#import <lexer.h>

static NSString* source;

int main(int argc, char* argv[]) {
  if (argc == 2) @autoreleasepool {
    source = [[NSString alloc] initWithCString: argv[1] encoding: NSUTF8StringEncoding];
    NSMutableArray<Token*>* tokens = lex(source);
    NSMutableArray<Node*>*  nodes  = parse(tokens);
    for (NSUInteger i = 0; i < nodes.count; i++)
      [[nodes objectAtIndex: i] evaluate];
  }
}
