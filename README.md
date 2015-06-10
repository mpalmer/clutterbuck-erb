This is a very, very simple gem -- it simply provides an `erb` method for
requests which renders a view template, with layouts, and returns the
resulting page.


# Installation

It's a gem:

    gem install clutterbuck-erb

There's also the wonders of [the Gemfile](http://bundler.io):

    gem 'gemplate'

If you're the sturdy type that likes to run from git:

    rake install

Or, if you've eschewed the convenience of Rubygems entirely, then you
presumably know what to do already.


# Usage

Load the code:

    require 'clutterbuck-erb'

Include the module in your app class:

    class MyExampleApp
      include Clutterbuck::ERB
    end

Create a template or two:

    $ mkdir views
    $ echo 'Ohai, <%= name %>!' >views/blah.html.erb

Call `erb` when you want to render a template, passing in any parameters you
want to use in rendering the template:

    class MyExampleApp
      get '/' do
        erb :blah, :name => params["name"] || "Fred"
      end
    end

For a request to `/`, this will render "Ohai, Fred!".  If you request
`/?name=Belle`, it will instead render "Ohai, Belle!".


## ERB Execution Context

Your ERB template is executed in a restricted environment, separate from the
app instance which is handling the request.  The only methods available are
those which you have specified as parameters to the `erb` call.


## Layouts

If you want to use a "common" template in which your various pages insert
themselves, you can do this in a couple of ways.  For a given response, you
can use `layout`:

    class MyExampleApp
      get '/' do
        layout :common

        erb :blah
      end
    end

Alternately, you can set a class-level default layout (and then override it
on a per-response basis):

    class MyExampleApp
      layout :common

      get '/' do
        layout :special if Time.now.to_i % 60 == 0

        erb :blah
      end
    end

The structure of a "layout" template is exactly the same as a regular
template, except that where you want to insert the page content, you place `<%=
yield %>`.

The hash of variables passed to `erb` are also available to the layout.


## For Further Assistance

There's a fair bit that goes on behind the scenes with the `erb` method, in
particular; you'll probably want to read the docs for {Clutterbuck::ERB}
(and to a lesser extent {Clutterbuck::ERB::ClassMethods}) to find out
everything that you can do.


# Contributing

Bug reports should be sent to the [Github issue
tracker](https://github.com/mpalmer/clutterbuck-erb/issues), or
[e-mailed](mailto:theshed+clutterbuck@hezmatt.org).  Patches can be sent as
a Github pull request, or
[e-mailed](mailto:theshed+clutterbuck@hezmatt.org).


# Licence

Unless otherwise stated, everything in this repo is covered by the following
copyright notice:

    Copyright (C) 2015  Matt Palmer <matt@hezmatt.org>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
