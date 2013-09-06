
module RPeg
    module Runtime
        class Vm
            attr_accessor :is_running, :success, :ip, :sb, 
                          :captures, :trace_op

            class VmUnderflow < Exception
            end

            def initialize(program)
                @program  = program
                @trace_op = false
            end

            def reset
                @ip         = 0
                @sb         = 0
                @sp         = 0
                @stack      = Array.new(255)
                @captures   = []
                @subject    = nil
                @is_running = false
                @success    = false
            end

            def run(subject)
                reset
                @subject = subject

                @is_running = true
                while @is_running do
                    step
                end
                @success
            end

            def step
                op = @program[@ip]
                puts op if trace_op
                op.call(self)
            end

            def fail
                puts 'backtracking' if trace_op
                while @sp > 0 and !tos.choice? do
                    pop
                end

                if @sp == 0 then
                    puts 'failed match' if trace_op
                    @is_running = false
                    @success = false
                else
                    @ip       = tos.ip
                    @sb       = tos.sb
                    @captures = tos.captures
                    pop
                end
            end

            def cur_c
                @subject[@sb]
            end

            def inc_ip(i = 1)
                @ip = @ip + i
            end

            def inc_sb(i = 1)
                @sb = @sb + i
            end

            def push(f)
                @stack[@sp] = f
                @sp = @sp + 1
            end

            def pop
                @sp = @sp - 1
            end

            def tos
                if @sp == 0 then
                    raise VmUnderflow.new
                end
                @stack[@sp - 1]
            end
        end
    end
end

