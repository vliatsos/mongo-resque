Resque-Mongo
============

Resque-Mongo is a fork of Resque based on MongoDB instead of Redis.

Check out the [ORIGINAL_README][0] included in this repository
for the general Resque lowdown.

What did you guys do to Resque?
===============================

Apart from transparently replacing the redis backend with mongodb
(where each queue has a corresponding mongo collection) this fork
also features delayed jobs if you want to schedule your jobs.

Delayed Jobs
------------

If your job class indicates that @delayed_jobs = true, you can queue
delayed jobs.  These jobs will not be popped off the queue until the
Time indicated in arg[0][:delay_until] has come.  Note that you must
call Resque.enable_delay(:queue) before enququing any delayed jobs, to
ensure that the performance impact on other queues is minimal.

Stern Warnings
--------------

Sometimes, Resque-Mongo will drop a queue collection, or create some 
indexes, or otherwise manipulate its database.  For this reason, it is
STRONGLY recommended that you give it its own database in mongo.

All jobs should be queued via Resque.enqueue.  All arguments passed to
this method must be BSON-encodable.  Resque-Mongo does not serialize
your objects for you.  Arrays, Hashes, Strings, Numbers, and Times
are all ok, so don't worry.

Many of the new queue-level features require the first argument of
your perform method to be an options hash.  In fact, if you just start
making all your perform()s take one param, that is an options hash,
you'll probably save yourself some pain.

Resque-Mongo will not create any indexes on your queues, only on its
meta-data.  You will need to create any indexes you want.  Normally,
This is not a problem, because you aren't querying by keys, but you may
want to create indexes on the class key in some circumstances.  If you 
use the unique or delay features, you may want some additional indexes, 
depending on the nature of your workload.  Paranoid?  Test enqueuing and 
processing all your jobs, and run with --notablescans.  Learn the profiler,
and use it often.

Specifically, a queue with many long-delayed jobs will result in slower queue pops
for all jobs using that queue.  Index delay_until in the case of
thousands of delayed jobs.

[0]: https://github.com/dbackeus/resque-mongo/blob/master/ORIGINAL_README.markdown
