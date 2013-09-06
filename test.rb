
require 'test/unit'
require 'ops'
require 'vm'

class TestVm < Test::Unit::TestCase
    include RPeg::Runtime

    def test_char
        vm = Vm.new([CharOp.new(?a), End])
        vm.run("a")
        assert(vm.success)
    end

    def test_char_fail
        vm = Vm.new([CharOp.new(?a), End])
        vm.run("b")
        assert(!vm.success)
    end

    def test_choice
        vm = Vm.new([ChoiceOp.new(3), CharOp.new(?a), CommitOp.new(2),
                     CharOp.new(?b), End])

        vm.run("a")
        assert(vm.success)

        vm.run("b")
        assert(vm.success)

        vm.run("c")
        assert(!vm.success)
    end

    def test_simple_repeat
        vm = Vm.new([ChoiceOp.new(3), CharOp.new(?a), 
                     PartialCommit.new(-1), End])

        vm.run("a")
        assert(vm.success)
        vm.run("aaaaa")
        assert(vm.success)
        vm.run("")
        assert(vm.success)
    end

    def test_failtwice
        vm = Vm.new([ChoiceOp.new(3), CharOp.new(?a),
                     FailTwice, End])
        assert(!vm.run("a"))
        assert(vm.run("b"))
    end

    def test_backcommit
        vm = Vm.new([ChoiceOp.new(3), CharOp.new(?a),
                     BackCommitOp.new(2), Fail, End])
        assert(vm.run("a"))
        assert(!vm.run("b"))
    end

end
