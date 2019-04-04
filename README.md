# MagicJSON
A JSON wrapper that covers most-frequent usages 


### Things that SwiftyJSON did not cover ###

SwiftyJSON is great, but it does not support the most important usage in development.

```Swift
enum P: String, Codable {
  case someKey
}
let pj = [P.someKey: "some value"]
let json = JSON(pj)
print(json[P.someKey])  // should print "some value"
```

Sure you can add extension to support it, but it'd be cubersome in some cases.

This one-file library covers all common usages of SwiftyJSON with additional support for enum key.

### Usage ###

```Swift
let mj = MJ([P.someKey: [P.someKey: [0, 1, 2, 3, 4, 5]]])
print(mj[P.someKey][P.someKey][3].intValue) // should print 3

```

It should work as SwiftyJSON in most-frequent usages. 

But this might not work for you if you use SwiftyJSON very differently.

### Further updates ###

Write this in playground, may miss something. Update later when I find it.

