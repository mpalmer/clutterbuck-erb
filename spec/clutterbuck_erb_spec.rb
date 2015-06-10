require_relative './spec_helper'
require 'clutterbuck-erb'

class TestApp
	include Clutterbuck::ERB

	def do_eeet(view, vars, teh_layout = nil)
		if teh_layout
			layout teh_layout
		end

		erb view, vars
	end
end

describe Clutterbuck::ERB do
	let(:response) { TestApp.new.do_eeet(view, vars, layout) }
	let(:vars)     { {} }
	let(:layout)   { nil }

	let(:status)  { response[0] }
	let(:headers) { response[1] }
	let(:body)    { response[2].join }

	def header(name)
		headers.select { |h| h.first.downcase == name.downcase }.map(&:last)
	end

	context "by default" do
		it "sets the view dir to something sensible" do
			expect(TestApp.views).to eq('./views')
		end
	end

	context "overridden view dir" do
		before(:each) do
			TestApp.views File.expand_path("../fixtures/views", __FILE__)
		end

		it "overrides the view dir" do
			expect(TestApp.views).to eq(fixture_file("views"))
		end
	end

	context "a simple no-vars template" do
		let(:view) { :arithmetic }

		it "returns OK" do
			expect(status).to eq(200)
		end

		it "sets Content-Length" do
			expect(header("Content-Length")).to eq([2])
		end

		it "sets Content-Type" do
			expect(header("Content-Type")).to eq(["text/html; charset=utf-8"])
		end

		it "produces the correct output" do
			expect(body).to eq("4\n")
		end
	end

	context "template with vars" do
		let(:view) { :var_list }
		let(:vars) { { :foo => "bar", :baz => "wombat" } }

		it "sets Content-Length" do
			expect(header("Content-Length")).to eq([25])
		end

		it "lists the vars" do
			expect(body).to eq("foo => bar\nbaz => wombat\n")
		end
	end

	context "template trying to call request methods" do
		let(:view) { :calls_do_eeet }

		it "explodes" do
			expect { response }.to raise_error(NameError)
		end
	end

	context "vars contains key of invalid type" do
		let(:view) { :var_list }

		let(:vars) { { Array.new => "lololol" } }

		it "explodes" do
			expect { response }.
			  to raise_error(ArgumentError, /Invalid key in vars list: \[\]/)
		end
	end

	context "vars isn't a hash" do
		let(:view) { :var_list }

		let(:vars) { [] }

		it "explodes" do
			expect { response }.
			  to raise_error(ArgumentError, /vars must be a hash/)
		end
	end

	context "vars contains key of invalid name" do
		let(:view) { :var_list }

		let(:vars) { { "oh!my!god!" => "lololol" } }

		it "explodes" do
			expect { response }.
			  to raise_error(ArgumentError, /Invalid key in vars list: "oh!my!god!"/)
		end
	end

	context "with a class-level layout" do
		let(:view) { :arithmetic }

		before(:each) do
			TestApp.layout :default
		end

		after(:each) do
			TestApp.layout nil
		end

		it "renders with the layout" do
			expect(body).to eq("Content goes here: 4\n")
		end

		it "accounts for the layout in the content length" do
			expect(header("Content-Length")).to eq([21])
		end
	end

	context "with a request-level layout" do
		let(:view)   { :arithmetic }
		let(:layout) { :default }

		it "renders with the layout" do
			expect(body).to eq("Content goes here: 4\n")
		end

		it "accounts for the layout in the content length" do
			expect(header("Content-Length")).to eq([21])
		end
	end
end
