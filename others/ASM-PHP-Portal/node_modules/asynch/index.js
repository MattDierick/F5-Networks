'use strict';

var async = require('async')

Function.prototype.passerr = function (cb, thisobj) {
    var fn = this
    return function (err) {
        var args = Array.prototype.slice.call(arguments, 1)
        if (err) {
            cb(err)
        } else {
            fn.apply(thisobj, args)
        }
    }
}

Function.prototype.throwerr = function (thisobj) {
    var fn = this
    return function (err) {
        var args = Array.prototype.slice.call(arguments, 1)
        if (err) {
            throw(err)
        } else {
            fn.apply(thisobj, args)
        }
    }
}

var asynch = module.exports = function asynch(name, fn) {
    var currentChunk = {series:[], parallel:[]}
    var chunks = [currentChunk]

    var result = {}
    var done
    var prevvalue = [null]

    function addChunk() {
        currentChunk = {series:[], parallel:[]}
        chunks.push(currentChunk)
    }

    function makeCallbackWrapper(name, saveInPrev, cb) {
        return function (err) {
            var value = Array.prototype.slice.call(arguments, 1)

            if (saveInPrev) {
                prevvalue = value
            }

            if (value.length) {
                if (value.length === 1) {
                    value = value[0]
                }

                if (name) {
                    result[name] = value
                }
            }

            cb(err)
        }
    }

    function makeArgs(fn, cb, usePrev) {
        var len = fn.length - 1
        if (len < 0) len = 0

        var args
        if (usePrev) {
            args = prevvalue
        } else {
            args = [result]
        }
        
        args = Array.prototype.slice.call(args, 0, len)
        args.push(cb)
        return args
    }

    function pushFunc(fn, type, name, saveInPrev, usePrev) {
        if (fn) currentChunk[type].push(function (cb) {
            var callback = makeCallbackWrapper(name, saveInPrev, cb)
            try {
                fn.apply(null, makeArgs(fn, callback, usePrev))
            } catch (err) {
                callback(err)
            }
        })
    }

    var obj = {
        thenp: function (name, fn) {
            if (!fn) {
                fn = name
                name = '_prev'
            }

            pushFunc(fn, 'series', name, true, true)
            return this
        },
        then: function (name, fn) {
            if (!fn) {
                fn = name
                name = '_prev'
            }

            pushFunc(fn, 'series', name, true, false)
            return this
        },
        parallel: function (name, fn) {
            if (!fn) {
                fn = name
                name = null
            }

            pushFunc(fn, 'parallel', name, false, false)
            return this
        },
        sync: function (name, fn) {
            addChunk()
            if (name) {
                this.then(name, fn)
                addChunk()
            }
            return this
        },
        syncp: function (name, fn) {
            addChunk()
            if (name) {
                this.thenp(name, fn)
                addChunk()
            }
            return this
        },
        donep: function (fn) {
            done = function (err) {
                var args = Array.prototype.slice.call(prevvalue)
                args.unshift(err)
                fn.apply(null, args)
            }
        },
        done: function (fn) {
            done = function (err) {
                fn(err, result)
            }
        },
        use: function (res, callback) {
            if (!callback) {
                if (typeof(res) === 'function') {
                    callback = res
                    res = null
                }
            }

            if (res) {
                result = res
            }

            this.done(callback)
            return this
        }
    }

    obj.thenp(name, fn)

    process.nextTick(function () {
        var doneFired = false
        async.eachSeries(chunks, function (chunk, cb) {
            if (doneFired) return cb()

            if (chunk.parallel.length) {
                var tasks = chunk.parallel
                if (chunk.series.length) {
                    var tasks = tasks.slice()
                    tasks.push(function (cb) {
                        async.series(chunk.series, function (err) {
                            if (err === 'done') {
                                err = null
                                doneFired = true
                            }
                            cb(err)
                        })
                    })
                }
                async.parallel(tasks, cb)
            } else if (chunk.series.length) {
                async.series(chunk.series, function (err) {
                    if (err === 'done') {
                        err = null
                        doneFired = true
                    }
                    cb(err)
                })
            } else {
                cb()
            }
        }, done)
    })

    return obj
}

asynch.parallel = function (name, fn) {
    return asynch().parallel(name, fn)
}

asynch.then = function (name, fn) {
    return asynch().then(name, fn)
}

asynch.use = function (result, callback) {
    return asynch().use(result, callback)
}
