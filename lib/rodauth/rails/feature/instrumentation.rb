module Rodauth
  module Rails
    module Feature
      module Instrumentation
        def _around_rodauth
          rails_instrument_request { super }
        end

        private

        def redirect(*)
          rails_instrument_redirection { super }
        end

        def rails_instrument_request
          request = rails_request

          raw_payload = {
            controller: scope.class.superclass.name,
            action: "call",
            request: request,
            params: request.filtered_parameters,
            headers: request.headers,
            format: request.format.ref,
            method: request.request_method,
            path: request.fullpath
          }

          ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload)

          ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
            begin
              result = catch(:halt) { yield }

              response = ActionDispatch::Response.new *(result || [404, {}, []])
              payload[:response] = response
              payload[:status] = response.status

              throw :halt, result if result
            rescue => error
              payload[:status] = ActionDispatch::ExceptionWrapper.status_code_for_exception(error.class.name)
              raise
            ensure
              rails_controller_eval { append_info_to_payload(payload) }
            end
          end
        end

        def rails_instrument_redirection
          ActiveSupport::Notifications.instrument("redirect_to.action_controller", request: rails_request) do |payload|
            result = catch(:halt) { yield }

            response = ActionDispatch::Response.new(*result)
            payload[:status] = response.status
            payload[:location] = response.filtered_location

            throw :halt, result
          end
        end
      end
    end
  end
end