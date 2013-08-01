# encoding: UTF-8

require "rack"
require "oj"

require "core_ext/kernel"
require "core_ext/hash"
require "core_ext/object"

module Immanence
  class Request
    attr_reader :input

    def initialize(request, input)
      @__request__  = request
      @input = input
    end

    def method_missing(method, *args, &block)
      @__request__.send(method, *args, &block)
    end
  end # Request

  class Control
    I = λ { |i| Oj.load(i) }
    O = λ { |o| Oj.dump(o, mode: :compat) }

    LEVENSHTEIN = λ do |a, b|
      [(0..a.size).to_a].tap { |mx|
        (1..b.size).each do |j|
          mx << [j] + [0] * (a.size)
        end

        (1..b.size).each do |i|
          (1..a.size).each do |j|
            if a[j-1] == b[i-1]
              mx[i][j] = mx[i-1][j-1]
            else
              mx[i][j] = [
                mx[i-1][j],
                mx[i][j-1],
                mx[i-1][j-1]
              ].min + 1
            end
          end
        end
      }[-1][-1]
    end

    class << self
      alias_method :delegate_to, :send

      # Convenience methods
      def request() @request end
      def input() request.input end
      def params() ascertain(receiver, request.path).reverse_merge!(request.params) end

      # Naive implementation
      def before(&blk) yield end

      # Interface with Rack
      def call(env)
        @request = Request.new(Rack::Request.new(env), I[env["rack.input"]])

        delegate_to receiver
      rescue => ε
        → ({ error: ε }),
            { status: 500, headers:
              { "X-Message" => "[...] from a problem to the accidents that condition and resolve it." } }
      end

      # Define routes in the application
      def route(verb, path, &blk)
        meta_def(conjugate(verb, path)) { instance_eval &blk }
      end

      # Render responses
      def render(body=:ok, options={})
        options.reverse_merge!({ status: 200 })

        options[:headers] ||= {}
        options[:headers].reverse_merge!({
          "Content-Type" => "text/json", "X-Framework" => "Immanence" })

        Rack::Response.new(O[body], options[:status], options[:headers]).finish
      end

      alias_method :→, :render

    private

      def conjugate(verb, path) # :nodoc:
        "immanent_#{verb}_#{path}"
      end

      # @return [Hash] Hash of parameters gleaned from request signature
      def ascertain(method, path)
        [method.to_s.gsub(/immanent_\w*_/, ""), path].

        map     { |path| path.split("/")[1..-1] }.
        let     { |x, y| x.zip(y) }.
        select  { |x, _| x[0] == ":" }.
        map     { |x, y| { x[1..-1] => y } }.

        reduce({}, :merge).
        deep_symbolize_keys
      end

      # @return [String] most likely candidate method to invoke based on incoming route
      def receiver
        @receiver ||= methods.grep(/immanent_/).map { |method|
          { method: method, Δ: LEVENSHTEIN[method, conjugate(request.request_method, request.path)] }
        }.min_by { |x| x[:Δ] }[:method]
      end
    end # self
  end # Control
end # Immanence

Immanent = Immanence
