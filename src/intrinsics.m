#import <nodes.h>
#import <intrinsics.h>

#define INTRINSIC ^Value*(NSMutableArray<Value*>* args)

Value* (^applyOperator)(CGFloat, NSMutableArray<Value*>*, CGFloat (^)(CGFloat, CGFloat)) = ^Value*(CGFloat startValue, NSMutableArray<Value*>* values, CGFloat (^functor)(CGFloat, CGFloat)) {
  CGFloat result = startValue;
  for (Value* v in values) {
    if (v->type == VALUE_NUMBER) {
      result = functor(result, v->value.number);
    } else {
      NSLog(@"Wrong arguments to call");
      abort();
    }
  }
  return [[Value alloc] initWithNumber: result];
};

LSIntrinsic LSadd = INTRINSIC { return applyOperator(0, args, ^(CGFloat acc, CGFloat val) { return acc + val; }); };

LSIntrinsic LSsub = INTRINSIC { return applyOperator(0, args, ^(CGFloat acc, CGFloat val) { return acc - val; }); };

LSIntrinsic LSmul = INTRINSIC { return applyOperator(1, args, ^(CGFloat acc, CGFloat val) { return acc * val; }); };

LSIntrinsic LSdiv = INTRINSIC {
  return applyOperator(args[0]->value.number, args, ^(CGFloat acc, CGFloat val) {
    if (acc == args[0]->value.number && val == args[0]->value.number)
      return acc;
    return acc / val;
  });
};

LSIntrinsic LScar = INTRINSIC {
  if (args.count == 1 && args[0]->type == VALUE_LIST)
    return args[0]->value.list[0];
  return nil;
};

LSIntrinsic LScdr = INTRINSIC {
  if (args.count == 1 && args[0]->type == VALUE_LIST)
    return [[Value alloc] initWithList: [args[0]->value.list subarrayWithRange: NSMakeRange(1, [args[0]->value.list count] - 1)]];
  return nil;
};

Value* (^LSprint)(NSMutableArray<Value*>*) = ^Value*(NSMutableArray<Value*>* args) {
  NSMutableString* s = [[NSMutableString alloc] init];
  for (NSUInteger i = 0; i < args.count; i++) {
    [s appendString: [args[i] stringify]];
    [s appendString: @" "];
  }
  NSLog(@"%@", s);
  return nil;
};
