def assert(cond, msg=nil)
  raise AssertionError, (msg || "Assertion Error") unless cond
end

def assert_equal(obj1, obj2)
  assert(obj1 == obj2, "#{obj1} and #{obj2} should be equal")
end

import 'b'
import 'sub/dir', :as=>'foo'

assert(defined? b::B)

assert_equal("b", b::b)
assert_equal("dir", foo::dir)

def a; "a"; end
class A; end
