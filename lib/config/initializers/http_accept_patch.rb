module ActionDispatch
  module Http
    module MimeNegotiation
      # Patched to always accept at least HTML
      # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/6022-content-negotiation-fails-for-some-headers-regression#ticket-6022-10
      def accepts
        @env["action_dispatch.request.accepts"] ||= begin
          header = @env['HTTP_ACCEPT'].to_s.strip

          if header.empty?
            [content_mime_type]
          else
            Mime::Type.parse(header) << Mime::HTML
          end
        end
      end
    end
  end
end

