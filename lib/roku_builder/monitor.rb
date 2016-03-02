module RokuBuilder

  # Monitor development Logs
  class Monitor < Util

    # Initialize port config
    def init()
      @ports = {
        main: 8085,
        sg: 8089,
        task1: 8090,
        task2: 8091,
        task3: 8092,
        taskX: 8093,
      }
    end

    # Monitor a development log on the Roku device
    # @param type [Symbol] The log type to monitor
    # @param verbose [Boolean] Print status messages.
    def monitor(type:)
      telnet_config = {
        'Host' => @roku_ip_address,
        'Port' => @ports[type]
      }
      waitfor_config = {
        'Match' => /./,
        'Timeout' => false
      }

      thread = Thread.new(telnet_config, waitfor_config) {|telnet_config,waitfor_config|
        @logger.info "Monitoring #{type} console(#{telnet_config['Port']}) on #{telnet_config['Host'] }"
        connection = Net::Telnet.new(telnet_config)
        Thread.current[:connection] = connection
        all_text = ""
        while true
          connection.waitfor(waitfor_config) do |txt|
            all_text += txt
            while line = all_text.slice!(/^.*\n/) do
              puts line
            end
            if all_text == "BrightScript Debugger> "
              print all_text
              all_text = ""
            end
          end
        end
      }
      running = true
      while running
        @logger.info "Q to exit"
        command = gets.chomp
        if command == "q"
          thread.exit
          running = false
        else
          thread[:connection].puts(command)
        end
      end
    end
  end
end
