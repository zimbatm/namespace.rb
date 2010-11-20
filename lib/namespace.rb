# Namespaces for ruby.
#
# See Namespace#import
module Namespace
  @cache = {}
  class << self;
    attr_reader :cache
    include Namespace
  end
  
  module Def
    def self.included(mod)
      eigenclass = (class << mod
        # Override to not show Namespace::NS for all modules
        def inspect
          defined?(@__namespace__) ? "<#{@__namespace__} #{(constants+instance_methods).sort.join(', ')}>" : super
        end
        self
      end)
      eigenclass.send(:include, mod, Namespace)
    end
  end
    
  #
  # Loads a file according to the +namespace+ in the context of a module,
  # and returns that object.
  #
  # It's not a Python import, where the namespace is available. What you
  # get here, is a sort of Sandbox where constants defined in the file are
  # not polluting the global namespace but available on the returned object.
  # Since the returned object is a Module, it can be included in the current
  # module if you're also in the contect of a "Sandbox".
  #
  # #import has been chosen because the ruby namespace is already crowded
  # (require, load and include are already taken)
  #
  def import(namespace)
    namespace = namespace.to_s.gsub(/[\/\\:]+/, ':') # allow symbols
    
    # @__namespace__ is not available outside of the ruby top-level
    if defined?(@__namespace__) && namespace[0..0] != ":"
      # expand namespace
      namespace = @__namespace__.sub(/:[^:]+$/,'') + ':' + namespace
    else
      namespace = ':' + namespace
    end
    puts "ns##{namespace}"
    
    # Cache lookup
    ns = Namespace::cache[namespace]
    return ns if ns
    
    file = nil
    # File lookup
    file_path = namespace[1..-1].gsub(':', File::SEPARATOR) + '.rb'
    $LOAD_PATH.each do |path|
      path = File.join(path, file_path)
      if File.exists? path
        file = path
        break
      end
    end
    
    raise LoadError, "no such file to load -- #{file_path}" unless file
    
    file_content = File.read(file_path)
    # Pre-process __NAMESPACE__ keyword to act like __FILE__
    # in know... it's not exactly the same... (eg "__FILE__") but it should do the trick
    file_content.gsub!('__NAMESPACE__', namespace.inspect)
    
    # Make sure NS is new (in the cases where the current NS requires another NS)
    Object.send(:remove_const, :NS) rescue nil
    # String is on 1 line to make sure line-errors are preserved
    ns = eval("module NS; @__namespace__ = #{namespace.inspect}; include Namespace::Def; #{file_content}; self; end", TOPLEVEL_BINDING, file)
    
    # Cache
    Namespace::cache[namespace] = ns
    
    return ns
  ensure
    Object.send(:remove_const, :NS) rescue nil
  end
end

# Make #import available to all
class Object; include Namespace; end

if __FILE__ == $0
  require 'irb'
  require 'irb/completion'
  IRB.start
end