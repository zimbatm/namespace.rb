# Namespaces for ruby.
#
# See Namespace.open and Namespace#import for more details
module Namespace
  @cache = {}
  @load_path = $LOAD_PATH
  class << self;
    attr_reader :cache
    attr_reader :load_path

    # Loads a file according to the +namespace+ in the context of a module,
    # and returns that object.
    #
    # It's not a Python import, where the namespace is available. What you
    # get here, is a sort of Sandbox where constants defined in the file are
    # not polluting the global namespace but available on the returned object.
    # Since the returned object is a Module, it can be included in the current
    # module if you're also in the context of a "Sandbox".
    def open(namespace)
      namespace = normalize(namespace)

      # Cache lookup
      ns = @cache[namespace]
      return ns if ns

      # File lookup
      file_path = namespace.gsub(':', File::SEPARATOR) + '.rb'
      file = @load_path.inject(nil) do |file, load_path|
        path = File.join(load_path, file_path)
        File.exists?(path) ? path : file
      end

      raise ImportError, "no such file to load -- #{file_path}" unless file

      file_content = File.read(file)
      # Pre-process __NAMESPACE__ keyword to act like __FILE__
      # in know... it's not exactly the same... (eg "__FILE__") but it should do the trick
      file_content.gsub!('__NAMESPACE__', namespace.inspect)

      ns = Module.new
      ns.instance_variable_set("@__namespace__", namespace)
      # Allow calling methods in self, like in global namespace
      ns.extend(ns)
      # Adds the #import methods from the DSL
      ns.extend(Namespace, Namespace::Ext)
      ns.module_eval(file_content, file)

      # Cache
      @cache[namespace] = ns

      return ns
    end

    # Transforms a string into a normalized namespace identifier
    #
    # Example:
    #   normalize("/: foo:bar/\baz ")
    #   => foo::bar::baz
    def normalize(namespace)
      namespace.to_s.sub(/^[\/:\s]*/, '').sub(/[\/:\s]*$/, '').gsub(/[\/\\:]+/, '::')
    end

    # Returns the top name of a namespace
    #
    # Example:
    #     basename("some::deep::namespace") => "namespace"
    def basename(namespace)
      normalize(namespace).gsub(/.*::/,'')
    end

  private

    # Namespace modules are not intended to be included.
    # This ensures that if they are, a ScriptError is
    # going to be raised.
    def included(mod)
      raise ScriptError, "Namespace is not designed to be included, only extended. See #{mod}"
    end
  end


  # options[:as] = select the imported name
  #
  # THINK: since variable is already returned, is :as necessary?
  #
  # #import has been chosen because the ruby namespace is already crowded
  # (require, load and include are already taken)
  def import(namespace, options={})
    mod = Namespace.open(namespace)

    name = options[:as] || options['as'] || Namespace.basename(namespace)
    raise ConflictError, "name `#{name}` is already taken" if method_defined?(name)
    instance_variable_set("@#{name}", mod)
    attr_reader name
    private name

    mod
  end

  # Used to override #inspect and #to_s of a namespace
  module Ext
    attr_reader :__namespace__
    alias inspect __namespace__
    alias to_s __namespace__
    private :__namespace__
  end

  class ImportError < ScriptError; end
  class ConflictError < ScriptError; end
end
