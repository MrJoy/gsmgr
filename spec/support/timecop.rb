# frozen_string_literal: true

# Borrowed from:
# https://github.com/evilmartians/terraforming-rails/tree/master/tools/timecop_linter

# MIT License
#
# Copyright (c) 2019 Evil Martians
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Warn if Timecop hasn't been returned at the end of the top-level example group.
#
# rubocop:disable Style/ClassAndModuleChildren
module TimecopLinter
  class Listener # :nodoc:
    NOTIFICATIONS = %i[
      example_group_finished
    ].freeze

    def example_group_finished(notification)
      return unless notification.group.top_level?
      return unless Timecop.frozen?

      # N.B. This won't _fail_ a test run -- it'll just produce a warning!
      TestProf.log(
        :error,
        "📛 ⏰ 📛 Timecop hasn't returned at the end of the test file!\n" \
        "File: #{notification.group.metadata[:location]}\n"
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren

RSpec.configure do |config|
  config.before(:suite) do
    listener = TimecopLinter::Listener.new

    config.reporter.register_listener(
      listener, *TimecopLinter::Listener::NOTIFICATIONS
    )
  end
end
