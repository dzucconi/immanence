#MVC <del>M</del>VC <del>MV</del>C

```ruby
class App < Immanence::Control
  route :get, "/hello" do
    object = { hello: "World" }

    re out object
  end

  route :get, "/new" do
    re "new"
  end
end
```

```
  GET /hello #=> {"hello":"World"}
  GET /hi    #=> {"hello":"World"}
  GET /new   #=> "new"
  GET /      #=> "new"
```
