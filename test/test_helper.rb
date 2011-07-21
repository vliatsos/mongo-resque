require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)
require 'resque' # because bundler looked for resque-igo

$TESTING = true
require 'test/unit'

begin
  require 'leftright'
rescue LoadError
end

##
# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
#
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
  # XXX: In 1.8.x, not all tests will run unless anonymous classes are kept in scope.
  ($test_classes ||= []) << klass
end

##
# Helper to perform job classes
#
module PerformJob
  def perform_job(klass, *args)
    resque_job = Resque::Job.new(:testqueue, 'class' => klass, 'args' => args)
    resque_job.perform
  end
end

#
# fixture classes
#

class SomeJob
  def self.perform(repo_id, path)
  end
end

class SomeIvarJob < SomeJob
  @queue = :ivar
end

class SomeMethodJob < SomeJob
  def self.queue
    :method
  end
end

class BadJob
  def self.perform
    raise "Bad job!"
  end
end

class GoodJob
  def self.perform(name)
    "Good job, #{name}"
  end
end

class BadJobWithSyntaxError
  def self.perform
    raise SyntaxError, "Extra Bad job!"
  end
end

class DelayedJob
  @queue = :delayed
  @delayed = true
  def self.perform(data)
    "delayed job executing #{data.inspect}"
  end
end

class MistargetedDelayedJob
  @queue = :unique
  @delayed = true
  def self.perform(data)
    " mistargeteddelayed job executing #{data.inspect}"
  end
end

class NonDelayedJob
  @queue = :delayed
end

class BadFailureBackend < Resque::Failure::Base
  def save
    raise Exception.new("Failure backend error")
  end
end

def with_failure_backend(failure_backend, &block)
  previous_backend = Resque::Failure.backend
  Resque::Failure.backend = failure_backend
  yield block
ensure
  Resque::Failure.backend = previous_backend
end

class Time
  # Thanks, Timecop
  class << self
    alias_method :now_without_mock_time, :now

    def now_with_mock_time
      $fake_time || now_without_mock_time
    end

    alias_method :now, :now_with_mock_time
  end
end
