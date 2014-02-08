module InlineTimeout
  module_function

  def self.timeout(seconds, interval=nil)
    start = Time.now.to_i
    begin
      result = yield
      return if result
      sleep(interval) if interval && interval > 0
    end until (Time.now.to_i - start) > seconds
    raise Error, "Timeout after #{seconds} seconds"
  end

  class Error < StandardError; end
end
