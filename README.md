> [...] when I stub my toe, it is because I do not have the proper set of architectural 
> landing sites in place. That is, my architectural body has not assembled enough clues to 
> connect itself properly to its surroundings. Sites of reversible destiny 
> are designed to be as complex as our most innate mechanisms of our perception.
> It might take an hour to go from one room to another, and I 
> might live there in a continual state of deja vu as I experience a repetition 
> of slightly differing perceptions. Yet, I will be involved in a constant critique
> of my own experience. I will see. I will live. Perhaps for the first time.
—Arakawa and Gins


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
