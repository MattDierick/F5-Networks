'use strict';

var assert = require('assert')

var asynch = require('./')

it('thenp should take previous return value as argument', function (done) {
    asynch(function (cb) {
        cb(null, 'val')
    }).thenp(function (val, cb) {
        assert.equal(val, 'val')
        cb()
    }).done(done)
})

it('thenp should take several return values as arguments', function (done) {
    asynch(function (cb) {
        cb(null, 'val1', 'val2')
    }).thenp(function (val1, val2, cb) {
        assert.equal(val1, 'val1')
        assert.equal(val2, 'val2')
        cb()
    }).done(done)
})

it('thenp should take callback as last argument', function (done) {
    asynch(function (cb) {
        cb(null, 'val1', 'val2')
    }).thenp(function (cb) {
        cb(null, 'boo', 'foo')
    }).thenp(function (boo, cb) {
        cb(null, boo, 'bar')
    }).donep(function (err, boo, bar) {
        assert.equal(boo, 'boo')
        assert.equal(bar, 'bar')
        done()
    })
})

it('then/done should take result as argument', function (done) {
    asynch('boo', function (cb) {
        cb(null, 'val')
    }).then(function (result, cb) {
        assert.equal(result.boo, 'val')
        cb()
    }).done(function (err, result) {
        assert.equal(result.boo, 'val')
        done()
    })
})

it('unnamed then/thenp should go to _prev', function (done) {
    asynch(function (cb) {
        cb(null, 'val')
    }).then(function (result, cb) {
        assert.equal(result._prev, 'val')
        cb()
    }).done(done)
})

it('"done" error should return null error in donep', function (done) {
    asynch(function (cb) {
        cb('done', 'val')
    }).then(function (result, cb) {
        assert(false, 'skip')
        cb()
    }).donep(function (err, val) {
        assert.ifError(err)
        assert.equal(val, 'val')
        done()
    })
})

it('"done" error should return null error in done', function (done) {
    asynch(function (cb) {
        cb('done', 'val')
    }).then(function (result, cb) {
        assert(false, 'skip')
        cb()
    }).done(function (err, result) {
        assert.ifError(err)
        assert.equal(result._prev, 'val')
        done()
    })
})

it('parallel should set named result', function (done) {
    asynch
    .parallel('boo', function (cb) {
        cb(null, 'boo')
    })
    .done(function (err, result) {
        assert.equal(result.boo, 'boo')
        done()
    })
})

it('parallel should run concurently', function (done) {
    var tm = process.hrtime()
    asynch('before', function (cb) {
        setTimeout(function () {
            cb(null, 'first')
        }, 10)
    })
    .parallel(function (result, cb) {
        setTimeout(function () {
            var ms = process.hrtime(tm)[1] / 1000000
            assert(ms > 18)
            assert(ms < 23)
            assert.equal(result.before, 'first')
            assert(!result.after)
            cb()
        }, 20)
    })
    .then('after', function (cb) {
        setTimeout(function () {
            cb(null, 'second')
        }, 30)
    })
    .done(function (err, result) {
        assert.equal(result.after, 'second')
        done()
    })
})

it('sync points should wait prevous chunk to complete', function (done) {
    asynch
    .parallel('foo', function (cb) {
        setTimeout(function () {
            cb(null, 'foo')
        }, 10)
    })
    .parallel('bar', function (cb) {
        setTimeout(function () {
            cb(null, 'bar')
        }, 10)
    })
    .sync()
    .parallel(function (result, cb) {
        assert.equal(result.foo, 'foo')
        cb()
    })
    .parallel(function (result, cb) {
        assert.equal(result.bar, 'bar')
        cb()
    })
    .done(done)
})

it('static then', function (done) {
    asynch
    .then(function (cb) {
        cb(null, 'boo')
    })
    .donep(function (err, value) {
        assert.equal(value, 'boo')
        done()
    })
})

it('sync points with callbacks should wait for its finish', function (done) {
    asynch
    .parallel('boo', function (cb) {
        setTimeout(function () {
            cb(null, 'boo')
        }, 10)
    })
    .parallel('foo', function (cb) {
        setTimeout(function () {
            cb(null, 'foo')
        }, 10)
    })
    .sync('bar', function (result, cb) {
        assert.equal(result.boo, 'boo')
        assert.equal(result.foo, 'foo')
        setTimeout(function () {
            cb(null, 'bar')
        }, 10)
    })
    .parallel(function (result, cb) {
        assert.equal(result.boo, 'boo')
        assert.equal(result.foo, 'foo')
        assert.equal(result.bar, 'bar')
        cb()
    }).done(done)
})

it('callback null values', function (done) {
    asynch
    .then('boo', function (cb) {
        cb()
    })
    .then('foo', function (cb) {
        cb(null, null)
    }).done(function (err, result) {
        assert(result.boo === undefined)
        assert(result.foo === null)
        done()
    })
})

it('use should change passed result', function (done) {
    asynch
    .then(function (result, cb) {
        asynch.use(result, cb)
        .then('boo', function (cb) {
            cb(null, 'boo')
        })
    })
    .then(function(result, cb) {
        assert.equal(result.boo, 'boo')
        cb()
    })
    .done(done)
})

it('use should take single callback argument', function (done) {
    asynch
    .then(function (result, cb) {
        asynch.use(cb)
        .then(function (cb) {
            result.boo = 'boo'
            cb()
        })
    })
    .then(function(result, cb) {
        assert.equal(result.boo, 'boo')
        cb()
    })
    .done(done)
})

it('use should take single result argument', function (done) {
    asynch
    .then(function (result, cb) {
        asynch.use(result)
        .then('boo', function (cb) {
            cb(null, 'boo')
        })
        .done(cb)
    })
    .then(function(result, cb) {
        assert.equal(result.boo, 'boo')
        cb()
    })
    .done(done)
})

it('asynch should catch exceptions', function (done) {
    asynch
    .then(function (cb) {
        throw new Error('boo')
    })
    .done(function (err) {
        assert.equal(err.message, 'boo')
        done()
    })
})

it('thenp should save named result', function (done) {
    asynch
    .then('one', function (cb) {
        cb(null, 1)
    })
    .thenp('two', function(one, cb) {
        cb(null, one + 1)
    })
    .thenp('three', function(two, cb) {
        cb(null, two + 1)
    })
    .then(function (result, cb) {
        assert.equal(result.one, 1)
        assert.equal(result.two, 2)
        assert.equal(result.three, 3)
        cb()
    })
    .done(done)
})
