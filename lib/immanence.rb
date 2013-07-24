require "rack"
require "oj"

require "./lib/core_ext/hash"
require "./lib/core_ext/object"

class Immanence
  I =-> i { Oj.load(i) }
  O =-> o { Oj.dump(o, mode: :compat) }

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

  PROBLEM = "[...] from a problem to the accidents that condition and resolve it."

  class Render
    def self.re(bdy=:ok, opts={}, hdrs={})
      opts.reverse_merge!({ status: 200 })
      hdrs.reverse_merge!({
        "Content-Type"      => "text/json",
        "Content-Length"    => ("#{bdy.size}" rescue "0")
      })

      [opts[:status], hdrs, [bdy]]
    end
  end

  class Control
    class << self
      def re(*args); Render.re(*args) end

      def out(o); O[o] end

      def route(verb, path, &blk)
        meta_def(conjugate(verb, path)) { instance_eval(&blk) }
      end

      def ascertain(method, path)
        deconjugate(method).
          split("/")[1..-1].
          zip(path.split("/")[1..-1]).
          collect do |x, y|
            { x[1..-1] => y } if x[0] == ":"
          end.
          compact.
          reduce({}, :merge).
          symbolize_keys
      end

      def deconjugate(method)
        method.to_s.gsub(/immanent_\w*_/, "")
      end

      def conjugate(verb, path)
        "immanent_#{verb}_#{path}"
      end

      def caller(e)
        { verb:       e["REQUEST_METHOD"].downcase,
          path:       e["PATH_INFO"],
          data:     I[e["rack.input"].read] }
      end

      def call(e)
        call = caller(e)

        receiver = methods.grep(/immanent_/).map { |method|
          { method: method, score: LEVENSHTEIN[method, conjugate(call[:verb], call[:path])] }
        }.min_by { |x| x[:score] }

        @params = ascertain(receiver[:method], call[:path])

        self.send(receiver[:method])
      end
    end
  end
end

# class App < Immanence::Control
#   route :get, "/notes/:id" do
#     re out @params[:id]
#   end

#   route :get, "/notes/:note_id/paragraphs/:id" do
#     re out @params
#   end

#   route :get, "/hello" do
#     object = { hello: "World" }

#     re out object
#   end

#   route :get, "/new" do
#     re "new"
#   end
# end
