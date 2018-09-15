# Finnegans

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'finnegans'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install finnegans

## Setup

You should first configure the namespace of the endpoints, by doing:

```ruby
Finnegans.setup do |config|
  config.resources_namespace = "personal"
end
```

In a Rails environment make sense to place this in an initializer.

This will help to identify the relevant resources expose by Finnegans. On the **App Builder -> Diccionario de APIs** you should declare each relevant endpoint like `personalSomeOtherName`. Also this will allow to avoid collisions with other exposed APIs endpoints.

## Usage

Everything is done via an instance of `Finnegans::Client`, to instantiate one you need to:

```ruby
client_args = {
  client_id: "", # Client Id for your user. You can generate them in your user profile and clicking on "Keys api"
  client_secret: "", # Client Secret for your user. You can generate them in your user profile and clicking on "Keys api"
  base_url: "" # This is the Base URL of the api. Something similar to 'https://X.teamplace.finneg.com/XXX/api/'
}

client = Finnegans::Client.new(client_args)
```

With this `client` you can get make requests to the API or `initialize_namespaced_resources`, like:

```ruby
client.initialize_namespaced_resources
```

and also if at this point you realize that you need a new namespaced resource in the API, you can run:

```ruby
client.initialize_namespaced_resources(refresh: true)
```

to recreate the resources on the client instance.

This method (`initialize_namespaced_resources`) dynamically defines instance methods on the `client` and initialize them as an instanced of `Finnegans::Resource`. So for example, if you have an API endpoint like `personalProducts` (the *personal* is an arbitrary name, could be whatever you want but must be the same that you specify in the `Finnegans.setup` block) that are *Tipo: Entidad* and supports `get` and `list` then you can do this with the `client`:

```ruby
client.products.list
# or
client.products.get([SOME_ID])
```

Notice that the method in the `client` is the same as the *non-namespaced* part of the API endpoint name. So as you can imagine, if you have another API endpoint called `personalProductCategories` then you can call `client.product_categories` and get the `Finnegans::Resource` instance).

> IMPORTANT: The only actions that are supported for now are **:get** and **:list**.

If the API endpoint is not a *Tipo: Entidad* but a *Tipo: Viewer* the only method expose in the resource is `.reports` so you can call:

```ruby
client.some_viewer.reports # The API endpoint name in this case, as you guessed, personalSomeViewer
```

## TO-DOs

  - Add `specs` for everything
  - Add the other actions (**:insert**, **:update**, **:delete**)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `rake console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nilusorg/finnegans.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
