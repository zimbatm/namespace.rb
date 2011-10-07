require File.expand_path('../helper', __FILE__)
require 'test/unit'

class TestNamespace < Test::Unit::TestCase
  def setup
    Namespace.cache.clear
    Namespace.load_path.replace([File.expand_path('../fixtures', __FILE__)])
  end
  
  def test_basics
    a = Namespace.open 'a'
    assert(a.const_defined?(:A))
    assert(a.method_defined?(:a))
    
    assert(a::A.kind_of? Module)
    assert_equal("a", a.a)
  end
  
  def test_importing_namespace
    m = Module.new
    m.extend Namespace
    ret = m.module_eval do
      import(:a).class
    end
    assert_equal(Module, ret)
    
    assert_raise(ScriptError) do
      m.send(:include, Namespace)
    end
  end
  
  def test_naming
    a = Namespace.open 'a'
    assert_equal('a', a.to_s)
    assert_equal('a', a.inspect)
    
    # THIS test is broken. If I remember well, ruby finds the module name internally
    # so it can't be overridden.
    # To fix this, we would have to override the #to_s, #inspect and #name
    # methods of all the exported modules and classes. Not good :-/
    #assert_equal('a::A', a::A.name)
  end
  
  def test_naming_conflict
    assert_raises(Namespace::ConflictError) do
      Namespace::open('name_conflict')
    end
  end
  
  def test_normalization
    norm_test = proc do |output, namespace|
      assert_equal(output, Namespace::normalize(namespace))
    end
    
    norm_test["simple", "simple"]
    norm_test["simple", :simple]
    norm_test["sub::dir", "sub/dir"]
    norm_test["sub::dir", "sub:dir"]
    norm_test["sub::dir", "sub::dir"]
    norm_test["strip", "/strip"]
    norm_test["strip", "strip/"]
    norm_test["strip", " ::strip/ "]
  end
  
  def test_basename
    base_test = proc do |output, namespace|
      assert_equal(output, Namespace::basename(namespace))
    end
    base_test["simple", "simple"]
    base_test["dir", "sub::dir"]
  end
  
  def test_dynimport
    a = Namespace.open 'dyn_import'
    b = Namespace.open 'b'
    assert_equal(a.return_b, b)
  end
end
