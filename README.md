```ruby
class App < Immanence::Control
  route :get, "/hello" do
    object = { hello: "World" }

    re out object
  end

  route :new, "/new" do
    re "new"
  end
end
```

```
  GET /hello #=> {"hello":"World"}
  GET /hi    #=> {"hello":"World"}
  GET /new   #=> "new"
```
