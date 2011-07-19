Mongo-Resque
============

Mongo-Resque is a fork of Resque based on MongoDB instead of Redis.

All work on this project is sponsored by the online video platform [Streamio](http://streamio.com).

[![Streamio](http://d253c4ja9jigvu.cloudfront.net/assets/small-logo.png)](http://streamio.com)

Check out the [ORIGINAL_README][0] included in this repository
for the general Resque lowdown.

What did you guys do to Resque?
===============================

Apart from transparently replacing the redis backend with mongodb
(where each queue has a corresponding mongo collection) this fork
also features delayed jobs if you want to schedule your jobs.

Note that this fork is different from IGO's fork in that queue
collections are namespaced with 'resque.queues.' to make it possible
to use the same database for your application as Resque (this might
still not be the best idea though - behold the stern warnings below).

Original resque is currently using hoptoad_notifier in its Hoptoad Failure
Backend. This fork has not implemented this change as I'm undecided wether 
the change was for the better or not (we avoid dependency troubles this way).

Delayed Jobs
------------

If your job class indicates that @delayed_jobs = true, you can queue
delayed jobs.  These jobs will not be popped off the queue until the
Time indicated in arg[0][:delay_until] has come.  Note that you must
call Resque.enable_delay(:queue) before enququing any delayed jobs, to
ensure that the performance impact on other queues is minimal.

Bundling
========

Make sure you use the right require in your Gemfile.

    gem 'mongo-resque', :require => 'resque'

Configuration
=============

Resque.redis= has been replaced with Resque.mongo= and expects a Mongo::DB
object as an argument.

    Resque.mongo = Mongo::Connection.new.db("my_awesome_queue")

Stern Warnings
==============

Sometimes, Mongo-Resque will drop a queue collection, or create some
indexes, or otherwise manipulate its database. For this reason, it is
STRONGLY recommended that you give it its own database in mongo.

All jobs should be queued via Resque.enqueue.  All arguments passed to
this method must be BSON-encodable. Mongo-Resque does not serialize
your objects for you.  Arrays, Hashes, Strings, Numbers, and Times
are all ok, so don't worry.

Many of the new queue-level features require the first argument of
your perform method to be an options hash.  In fact, if you just start
making all your perform()s take one param, that is an options hash,
you'll probably save yourself some pain.

Mongo-Resque will not create any indexes on your queues, only on its
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
