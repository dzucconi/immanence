# encoding: UTF-8

require "rack"
require "oj"

require "core_ext/kernel"
require "core_ext/hash"
require "core_ext/object"

module Immanence
  class Request < Struct.new(:verb, :path, :input); end

  class Control
    I = λ { |i| Oj.load(i) }
    O = λ { |o| Oj.dump(o, mode: :compat) }

    LEVENSHTEIN = λ { |a, b|
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
    }

    class << self
      def >>(body=:ok, options={}, headers={})
        body = O[body]

        options.reverse_merge!({ status: 200 })

        headers.reverse_merge!({
          "Content-Type"      => "text/json",
          "Content-Length"    => ("#{body.size}" rescue "0")
        })

        [options[:status], headers, [body]]
      end

      def route(verb, path, &blk)
        meta_def(conjugate(verb, path)) { instance_eval &blk }
      end

      def call(e)
        @request  = Request.new e["REQUEST_METHOD"].downcase, e["PATH_INFO"], I[e["rack.input"].read]
        @params   = ascertain receiver, @request.path

        send receiver
      rescue => ε
        # [...] from a problem to the accidents that condition and resolve it.
        self >> { error: ε }
      end

    private

      def conjugate(verb, path) # :nodoc:
        "immanent_#{verb}_#{path}"
      end

      # @return [Hash] Hash of request parameters
      def ascertain(method, path)
        [method.to_s.gsub(/immanent_\w*_/, ""), path].

        map     { |path| path.split("/")[1..-1] }.
        let     { |x, y| x.zip(y) }.
        select  { |x, y| x[0] == ":" }.
        map     { |x, y| { x[1..-1] => y } }.

        reduce({}, :merge).
        deep_symbolize_keys
      end

      # @return [String] most likely candidate method to invoke based on incoming route
      def receiver
        @receiver ||= methods.grep(/immanent_/).map { |method|
          { method: method, Δ: LEVENSHTEIN[method, conjugate(@request.verb, @request.path)] }
        }.min_by { |x| x[:Δ] }[:method]
      end
    end
  end
end
