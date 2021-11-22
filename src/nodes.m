#import <nodes.h>
#import <intrinsics.h>

@implementation Value
- (id)initWithNumber: (CGFloat)number {
  if (self = [super init]) {
    self->value.number = number;
    self->type = VALUE_NUMBER;
  }
  return self;
}

- (id)initWithString: (NSString*)string {
  if (self = [super init]) {
    self->value.string = string;
    self->type = VALUE_STRING;
  }
  return self;
}

- (id)initWithList: (NSMutableArray<Value*>*)list {
  if (self = [super init]) {
    self->value.list = list;
    self->type = VALUE_LIST;
  }
  return self;
}

- (id)initWithNode: (Node*)node {
  if (self = [super init]) {
    self->value.node = node;
    self->type = VALUE_NODE;
  }
  return self;
}

- (id)initWithFunc: (LSFunction*)func {
  if (self = [super init]) {
    self->value.func = func;
    self->type = VALUE_FUNCTION;
  }
  return self;
}

- (NSString*)stringify {
  switch (self->type) {
    case VALUE_NUMBER: return [[NSString alloc] initWithFormat: @"%f", self->value.number]; break;
    case VALUE_STRING: return [[NSString alloc] initWithFormat: @"%@", self->value.string]; break;
    case VALUE_FUNCTION: return [[NSString alloc] initWithFormat: @"Function %@", self->value.func->params]; break;
    case VALUE_LIST: {
      NSMutableString* s = [[NSMutableString alloc] init];
      [s appendString: @"["];
      for (NSUInteger i = 0; i < self->value.list.count - 1; i++) {
        [s appendString: [[self->value.list objectAtIndex: i] stringify]];
        [s appendString: @", "];
      }
      [s appendString: [[self->value.list objectAtIndex: self->value.list.count - 1] stringify]];
      [s appendString: @"]"];
      return s;
    } break;
    case VALUE_NODE: {
      Node* node = self->value.node;
      return [node stringify];
    }
  }
}
@end

@implementation Node
- (id)init: (NodeType)type {
  if (self = [super init])
    self->type = type;
  return self;
}

- (Value*)evaluate { return nil; }

- (NSString*)stringify {
  switch (self->type) {
    case NODE_IDENTIFIER: {
      IdentifierNode* iden = (IdentifierNode*)self;
      return [[NSString alloc] initWithString: iden->name];
    }
    case NODE_NUMBER: return [[NSString alloc] initWithFormat: @"%f", ((NumberNode*)self)->value];
    case NODE_STRING: return [[NSString alloc] initWithFormat: @"\"%@\"", ((StringNode*)self)->content];
    case NODE_LIST: {
      NSMutableString* s = [[NSMutableString alloc] init];
      [s appendString: @"("];
      NSMutableArray<Node*>* nodes = ((ListNode*)self)->items;
      [nodes enumerateObjectsUsingBlock: ^(Node* node, NSUInteger idx, BOOL* stop) { 
        [s appendString: [node stringify]];
        if (idx != nodes.count - 1) [s appendString: @" "];
      }];
      [s appendString: @")"];
      return [[NSString alloc] initWithString: s];
    }
  }
}
@end

@implementation NumberNode
- (id)init: (CGFloat)value {
  if (self = [super init: NODE_NUMBER])
    self->value = value;
  return self;
}

- (Value*)evaluate {
  return [[Value alloc] initWithNumber: self->value];
}
@end


NSMutableDictionary<NSString*, Value*>* variables = nil;

@implementation LSFunction
- (Value*)execute: (NSMutableArray<Value*>*)args {
  for (NSUInteger i = 0; i < self->params.count; i++)
    [variables setObject: args[i] forKey: self->params[i]];

  return [self->body evaluate];
}

- (id)init: (NSMutableArray<NSString*>*)params body: (Node*)body {
  if (self = [super init]) {
    self->params = params;
    self->body = body;
  }
  return self;
}
@end

NSMutableDictionary* functions = nil;

void initialiseFunctions() {
  functions = [[NSMutableDictionary alloc] init];
  // Binary operators
  [functions setObject: LSadd forKey: @"+"];
  [functions setObject: LSsub forKey: @"-"];
  [functions setObject: LSmul forKey: @"*"];
  [functions setObject: LSdiv forKey: @"/"];
  // S-expression functions
  [functions setObject: LScar forKey: @"car"];
  [functions setObject: LScdr forKey: @"cdr"];
  // IO
  [functions setObject: LSprint forKey: @"print"];
}

@implementation ListNode
- (id)init: (NSMutableArray<Node*>*)items {
  if (self = [super init: NODE_LIST])
    self->items = items;
  return self;
}

- (Value*)evaluate {
  if (functions == nil) initialiseFunctions();
  if (variables == nil) variables = [[NSMutableDictionary alloc] init];

  if ([items objectAtIndex: 0]->type == NODE_IDENTIFIER) {
    IdentifierNode* node = (IdentifierNode*)[items objectAtIndex: 0];
    if ([node->name isEqual: @"quote"] || [node->name isEqual: @"'"]) {
      if (self->items.count == 2) {
        Node* node = self->items[1];
        return [[Value alloc] initWithNode: node];
      } else {
        NSLog(@"quote expected one argument");
        abort();
      }
    } else if ([node->name isEqual: @"defun"]) {
      if (self->items.count == 4) {
        Node* name = self->items[1];
        Node* params = self->items[2];
        Node* body = self->items[3];

        NSMutableArray<NSString*>* paramNames = [[NSMutableArray alloc] init];
        for (Node* param in ((ListNode*)params)->items)
          [paramNames addObject: ((IdentifierNode*)param)->name];

        [variables setObject: [[Value alloc] initWithFunc: [[LSFunction alloc] init: paramNames body: body]] forKey: ((IdentifierNode*)name)->name];
        return nil;
      } else {
        NSLog(@"defun expected two arguments");
        abort();
      }
    } else {
      NSMutableArray<Value*>* elements = [[NSMutableArray alloc] init];
      for (NSUInteger i = 1; i < self->items.count; i++)
        [elements addObject: [self->items[i] evaluate]];

      if ([[variables allKeys] containsObject: node->name]) {
        if (variables[node->name]->type == VALUE_FUNCTION)
          return [variables[node->name]->value.func execute: elements];
      } else {
        Value*(^f)(NSMutableArray<Value*>*) = functions[node->name];

        return f(elements);
      }
    }
  } else {
    NSMutableArray<Value*>* elements = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < self->items.count; i++)
      [elements addObject: [self->items[i] evaluate]];
    return [[Value alloc] initWithList: elements];
  }
  return nil;
}
@end

@implementation IdentifierNode
- (id)init: (NSString*)name {
  if (self = [super init: NODE_IDENTIFIER])
    self->name = name;
  return self;
}

- (Value*)evaluate {
  return [variables valueForKey: self->name];
}
@end

@implementation StringNode
- (id)init: (NSString*)content {
  if (self = [super init: NODE_STRING])
    self->content = content;
  return self;
}

- (Value*)evaluate {
  return [[Value alloc] initWithString: self->content];
}
@end
