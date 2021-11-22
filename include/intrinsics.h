#import <nodes.h>

typedef Value* (^LSIntrinsic)(NSMutableArray<Value*>*);

LSIntrinsic LSadd, LSsub, LSmul, LSdiv, LSprint, LScar, LScdr;
