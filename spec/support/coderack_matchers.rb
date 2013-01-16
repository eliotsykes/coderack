module Coderack
  module Test
    module Matchers
      def self.included(base)
        [:bad_request, :unauthorized].each do |st|
          RSpec::Matchers.define(:"be_#{st}") do
            expected_status = Rack::Utils::SYMBOL_TO_STATUS_CODE[st]

            match do |rack|
              @status = rack.respond_to?(:status) ? rack.status : rack
              @inspect = rack

              @status == expected_status
            end

            failure_message_for_should do |not_string, rack|
              "Expected #{@inspect} status to be #{expected_status}, but it was #{@status}."
            end

            failure_message_for_should_not do |not_string, rack|
              "Expected #{@inspect} status not to be #{expected_status}."
            end
          end
        end

        RSpec::Matchers.define("redirect_to_login_page") do
          match do |response|
            match_unless_raises ::Test::Unit::AssertionFailedError do |_|
              assert_redirected_to(login_users_path)
            end
          end

          failure_message_for_should do |not_string, rack|
            "Expected #{@inspect} to redirect to login page, but it didn't."
          end

          failure_message_for_should_not do |not_string, rack|
            "Expected #{@inspect} not to redirect to login page, but it did."
          end
        end

      end
    end
  end
end
