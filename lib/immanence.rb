require "rack"
require "oj"

require "./lib/core_ext/hash"
require "./lib/core_ext/object"

class Immanence
  class Request < Struct.new(:verb, :path, :input); end

  class Control
    I =-> i { Oj.load(i) }
    O =-> o { Oj.dump(o, mode: :compat) }

    PROBLEM = "[...] from a problem to the accidents that condition and resolve it."

    LEVENSHTEIN =-> a, b {
      mx = [(0..a.size).to_a]

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

      mx[-1][-1]
    }

    class << self
      def >>(body=:ok, opts={}, headers={})
        body = O[body]
        opts.reverse_merge!({ status: 200 })
        headers.reverse_merge!({
          "Content-Type"      => "text/json",
          "Content-Length"    => ("#{body.size}" rescue "0")
        })

        [opts[:status], headers, [body]]
      end

      def route(verb, path, &blk)
        meta_def(conjugate(verb, path)) { instance_eval(&blk) }
      end

      def conjugate(verb, path)
        "immanent_#{verb}_#{path}"
      end

      def ascertain(method, path)
        method.to_s.gsub(/immanent_\w*_/, "").
          split("/")[1..-1].
          zip(path.split("/")[1..-1]).
          map { |x, y|
            { x[1..-1] => y } if x[0] == ":"
          }.compact.
          reduce({}, :merge).
          symbolize_keys
      end

      def receiver
        methods.grep(/immanent_/).map { |method|
          { method: method, score: LEVENSHTEIN[method, conjugate(@request.verb, @request.path)] }
        }.min_by { |x| x[:score] }[:method]
      end

      def call(e)
        @request  = Request.new e["REQUEST_METHOD"].downcase, e["PATH_INFO"], I[e["rack.input"].read]
        @params   = ascertain receiver, @request.path

        send receiver
      rescue
        self >> { error: PROBLEM }
      end
    end
  end
end

class App < Immanence::Control
  route :get, "/notes/:id" do
    self >> { id: @params[:id] }
  end

  route :get, "/notes/:note_id/paragraphs/:id" do
    self >> params
  end

  route :get, "/hello" do
    object = { hello: "World" }

    self >> object
  end

  route :get, "/new" do
    self >> "new"
  end
end
