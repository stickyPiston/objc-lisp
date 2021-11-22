#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NodeType) {
  NODE_NUMBER,
  NODE_STRING,
  NODE_IDENTIFIER,
  NODE_LIST
};

typedef NS_ENUM(NSUInteger, ValueType) {
  VALUE_NUMBER,
  VALUE_STRING,
  VALUE_LIST,
  VALUE_NODE,
  VALUE_FUNCTION
};

@class Node, LSFunction;

@interface Value : NSObject {
  @public union {
    CGFloat number;
    NSString* string;
    NSArray<Value*>* list;
    Node* node;
    LSFunction* func;
  } value;
  @public ValueType type;
}
- (id)initWithNumber: (CGFloat)number;
- (id)initWithString: (NSString*)string;
- (id)initWithList:   (NSArray<Value*>*)list;
- (id)initWithNode:   (Node*)node;
- (id)initWithFunc:   (LSFunction*)func;
- (NSString*)stringify;
@end

@interface LSFunction : NSObject {
  @public NSMutableArray<NSString*>* params;
  @public Node* body;
}

- (Value*)execute: (NSMutableArray<Value*>*)args;
- (id)init: (NSMutableArray<NSString*>*)params body: (Node*)body;
@end

@interface Node : NSObject {
  @public NodeType type;
}

- (Value*)evaluate;
- (id)init: (NodeType)type;
- (NSString*)stringify;
@end

@interface NumberNode : Node {
  @public CGFloat value;
}

- (id)init: (CGFloat)value;
@end

@interface ListNode : Node {
  @public NSMutableArray<Node*>* items;
}

- (id)init: (NSMutableArray<Node*>*)items;

@end

@interface IdentifierNode : Node {
  @public NSString* name;
}

- (id)init: (NSString*)name;

@end

@interface StringNode : Node {
  @public NSString* content;
}

- (id)init: (NSString*)content;

@end
