class Timer
  
    def start
        @start_time = Time.now
        return self
    end

    def stop
        @end_time = Time.now
        return self
    end

    # Return time in seconds
    def get_time
        if @end_time == nil
            return Time.now - @start_time
        else
            return @end_time - @start_time
        end
    end
end