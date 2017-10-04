require "test_helper"
require "fluent/plugin/out_remote_syslog"

class RemoteSyslogOutputTest < MiniTest::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag = "test.remote_syslog")
    Fluent::Test::OutputTestDriver.new(Fluent::RemoteSyslogOutput, tag) {}.configure(conf)
  end

  def test_program_from_record
    d = create_driver %[
      type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      tag orignal
    ]

    d.run do
      d.emit('message' => "foo", 'program' => 'record_based_program')
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    packet = logger.instance_variable_get(:@packet)
    assert_equal "record_based_program", packet.tag
  end

  def test_hostname_from_record
    d = create_driver %[
      type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      tag orignal
    ]

    d.run do
      d.emit('message' => "foo", 'local_hostname' => 'host.name')
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    packet = logger.instance_variable_get(:@packet)
    assert_equal "host.name", packet.hostname
  end
end
