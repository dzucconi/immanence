# Immanence

> [...] when I stub my toe, it is because I do not have the proper set of architectural landing sites in place.
> That is, my architectural body has not assembled enough clues to connect itself properly to its surroundings.
> Sites of reversible destiny are designed to be as complex as our most innate mechanisms of our perception.
> It might take an hour to go from one room to another, and I might live there in a continual state of deja vu as I experience a repetition of slightly differing perceptions.
> Yet, I will be involved in a constant critique of my own experience.
> I will see.
> I will live.
> Perhaps for the first time.
>
> —Arakawa and Madeline Gins

----

Immanence is a DSL for handling web requests in Ruby, built on top of Rack. To execute routes it calculates the Levenshtein distance between incoming requests and routes defined in the DSL then executes the most likely candidate. *Something will always be executed.* Objects are rendered by calling `>>` on `self` with the object to be rendered as the argument. Objects are serialized into JSON via Oj. Incoming JSON is automatically parsed and available in the `@request` object.

```ruby
class Application < Immanence::Control
  route :get, "/fields/:id" do
    self >> Field.find(@params[:id])
  end
  
  route :post, "/fields" do
    self >> Field.create(@request.input)
  end
end
```
