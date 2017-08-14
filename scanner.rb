class Scanner

  def initialize(ip:, object:, mode:)
    @scanner = WebSocket::Client::Simple.connect "ws://#{ip}:9999/"

    @scanner.on :open do
       puts 'connected!'
    end  

    @scanner.on :message do |msg|
      if mode == 'OUT'
        object.scanned_out(barcode: msg.data.strip)
      else
        object.scanned_in(barcode: msg.data.strip)
      end    
    end

    @scanner.on :close do |event|
      p event
    end

    @scanner.on :error do |event|
      p event
    end 
  end 

  def close
    @scanner.close
  end  
  
end
