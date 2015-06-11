require 'erb'
require 'rack'

#:nodoc:
module Clutterbuck; end

# Render an ERB template and return it as a Rack-compatible response.
#
module Clutterbuck::ERB
	# These are the methods which are available at the class level in your
	# Rack application class.
	#
	module ClassMethods
		#:nodoc:
		Unspecified = Module.new

		# Set or get the view directory for the app.
		#
		# @param v [String] a path, relative to the current working directory,
		#   from which view files should be read.
		#
		# @return [String]
		#
		def views(v=Unspecified)
			if v != Unspecified
				@views = v
			end
			@views || './views'
		end

		# Set or get the layout to use by default when rendering all templates.
		#
		# @param l [Symbol] The layout file to use.
		#
		# @return Symbol
		#
		def layout(l=Unspecified)
			if l != Unspecified
				@layout = l
			end
			@layout
		end
	end

	#:nodoc:
	#
	# Stuff the class methods into any module we're included in.
	#
	def self.included(mod)
		mod.extend(ClassMethods)
	end

	#:nodoc:
	#
	# A special (very, *very* special) class which only defines methods for
	# the vars that are passed into it, as well as fundamental HTML escaping
	# methods.
	#
	class EvalBinding < BasicObject
		def initialize(vars)
			unless vars.is_a?(::Hash)
				::Kernel.raise ::ArgumentError,
				      "vars must be a hash"
			end

			@vars = vars

			@vars.keys.each do |k|
				unless k.is_a?(::String) or k.is_a?(::Symbol)
					::Kernel.raise ::ArgumentError,
					      "Invalid key in vars list: #{k.inspect}"
				end

				unless k.to_s =~ /^[A-Za-z_][A-Za-z0-9_]*[\!\?]?$/
					::Kernel.raise ::ArgumentError,
					      "Invalid key in vars list: #{k.inspect}"
				end

				instance_eval "def #{k}; @vars[#{k.inspect}]; end"
			end
		end

		# HTML-escape the provided string.
		#
		def h(s)
			::Rack::Utils.escape_html(s)
		end
	end

	# Render an ERB template as a Rack response.
	#
	# Looks up the specified `view` in the `views` directory (`./views` by
	# default, or whatever you specify with the {ClassMethods#views} method),
	# and renders it as an ERB template in a special context which only
	# contains the methods specified by `vars`.
	#
	# Optionally, if {ClassMethods#layout} or {#layout} has been called, we
	# will render the given layout "around" the template itself.
	#
	# @param view [Symbol] a filename (without the `.html.erb` extension) in
	#   the `views` directory, which will be rendered by ERB.
	#
	# @param vars [Hash<Symbol, Object>] zero or more variables which should
	#   be made available in the rendering context.
	#
	# @return [Array<(Integer, Array<(String, String)>, Array<#to_s>)>] a
	#   Rack response.
	#
	def erb(view, vars)
		content = erbterpreter(view).result(get_binding(vars))

		layout = @layout || self.class.layout

		if layout
			content = erbterpreter(layout).result(get_binding(vars) { content.chomp })
		end

		[
			200,
			[
				["Content-Length", content.bytesize],
				["Content-Type", "text/html; charset=utf-8"]
			],
			[content]
		]
	end

	# Specify a layout to use for this request.  Works identically to
	# {ClassMethods#layout} in all the relevant particulars.
	#
	# @param l [Symbol]
	#
	def layout(l)
		@layout = l
	end

	private

	def get_binding(vars)
		EvalBinding.new(vars).instance_eval("::Kernel.binding")
	end

	def view_content(view)
		File.read(File.join(self.class.views, view.to_s + ".html.erb"))
	end

	def erbterpreter(view)
		ERB.new(view_content(view), 0, "%-")
	end
end
