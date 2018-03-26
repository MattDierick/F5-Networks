# Async helper

Yeah we all know about Promise/\* implementations. But in real life
we have to deal with promiseunaware code/libs and thats turns into endless
pain, completely unreadable wrapped wrappers macaroni.

So explicit callbacks is not a bad thing for now.

Asynch tries to solve a common flow problem — you have a bunch of functions.
Some of them can be run in parallel, others depend from previous results.
There is not a problem to directly call async#auto in simple cases. But what
about case when you need run parallel tasks after getting result from another
parallel tasks or run some series in parallel? Hello callbacks hell! 
Asynch allows to linearize such code.

## Quick example

```javascript
asynch
.parallel('res1', getRes1)
.parallel('res2', getRes2)
.sync('res3', transformRes1Res2IntoRes3)
.parallel(useOfRes3)
.parallel(anotherUseOfRes3)
.done(done)
```


## Result state

Each asynch instance keeps track of intermediate results. You can access it
as `result` object (then, parallel, sync, done):

```javascript
asynch
.then('one', function (cb) { 
    cb(null, 'one')
})
.then('two', function (result, cb) {
    cb(null, result.one + 'two')
})
.done(function (err, result) {
    console.log(result)
})
```

Or previous result (thenp, syncp, donep):

```javascript
asynch
.then(function (cb) { 
    cb(null, 'one', 'two', 'three')
})
.thenp(function (one, two, three, cb) {
    console.log(three)
    cb(null, one, two)
})
.done(function (err, one, two) {
    console.log(one, two)
})
```

Note: previous result is set by then/thenp/sync/syncp calls only.
parallel can set return value in result object.

TODO: result.\_prev

## Basic flow

