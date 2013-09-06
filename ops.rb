
require 'singleton'

module RPeg
    module Runtime
        class CharOp
            def initialize(c)
                @c = c
            end

            def call(vm)
                if @c == vm.cur_c then
                    vm.inc_ip
                    vm.inc_sb
                else
                    vm.fail
                end
            end
        end

        class ChoiceOp
            class Choice
                attr_accessor :ip, :sb, :captures

                def initialize(ip, sb, captures)
                    @ip = ip
                    @sb = sb
                    @captures = captures
                end

                def choice?
                    true
                end
            end

            def initialize(offset)
                @offset = offset
            end

            def call(vm)
                vm.push(Choice.new(vm.ip + @offset, vm.sb, vm.captures))
                vm.inc_ip
            end
        end

        class CommitOp
            def initialize(offset)
                @offset = offset
            end

            def call(vm)
                vm.inc_ip(@offset)
                vm.pop
            end
        end

        class BackCommitOp
            def initialize(offset)
                @offset = offset
            end

            def call(vm)
                vm.sb = vm.tos.sb
                vm.inc_ip(@offset)
                vm.pop
            end
        end

        class EndOp
            include Singleton

            def call(vm)
                vm.is_running = false
                vm.success = true
            end
        end

        class FailOp
            include Singleton

            def call(vm)
                vm.fail
            end
        end

        class FailTwiceOp
            include Singleton

            def call(vm)
                vm.pop
                vm.fail
            end
        end

        End       = EndOp.instance
        Fail      = FailOp.instance
        FailTwice = FailTwiceOp.instance
    end
end

