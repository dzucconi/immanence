#MVC <del>M</del>VC <del>MV</del>C

```ruby
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
```
