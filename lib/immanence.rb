require "rack"
require "oj"

require "./lib/core_ext/hash"
require "./lib/core_ext/object"

class Immanence
  I =->(i){ Oj.load(i) }
  O =->(o){ Oj.dump(o, mode: :compat) }

  LEVENSHTEIN =->(a, b){
    matrix = [(0..a.length).to_a]

    (1..b.length).each do |j|
      matrix << [j] + [0] * (a.length)
    end

    (1..b.length).each do |i|
      (1..a.length).each do |j|
        if a[j-1] == b[i-1]
          matrix[i][j] = matrix[i-1][j-1]
        else
          matrix[i][j] = [
            matrix[i-1][j],
            matrix[i][j-1],
            matrix[i-1][j-1]
          ].min + 1
        end
      end
    end

    matrix.last.last
  }

  PROBLEM = "[...] from a problem to the accidents that condition and resolve it."

  class Render
    def self.re(bdy=:ok, opts={}, hdrs={})
      opts.reverse_merge!({ status: 200 })
      hdrs.reverse_merge!({
        "Content-Type"      => "text/json",
        "Content-Length"    => (bdy.size.to_s rescue "0")
      })

      [opts[:status], hdrs, [bdy]]
    end
  end

  class Control
    class << self
      def re(*args); Render.re(*args) end
      def out(o); O.call(o) end

      def route(verb, path, &blk)
        meta_def(conjugate(verb, path)) { instance_eval(&blk) }
      end

      def conjugate(verb, path)
        "immanent_#{verb}_#{path}"
      end

      def caller(e)
        { method: e["REQUEST_METHOD"].downcase,
          path: e["PATH_INFO"],
          data: I.call(e["rack.input"].read) }
      end

      def call(e)
        call = caller(e)

        receiver = methods.grep(/immanent_/).map { |method|
          { m: method, s: LEVENSHTEIN.call(method, conjugate(call[:method], call[:path])) }
        }.min_by { |x| x[:s] }

        self.send(receiver[:m])
      end
    end
  end
end

class App < Immanence::Control
  route :get, "/hello" do
    object = { hello: "World" }

    re out object
  end

  route :new, "/new" do
    re "new"
  end
end
