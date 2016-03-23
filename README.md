# CanvasDataClient

This gem is meant to provide an easy-to-use ruby client wrapping the [Canvas](https://canvaslms.com) Hosted Data API.

It calculates and attaches HMAC signatures for each request, and returns the parsed JSON response.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'canvas_data_client', github: 'ben-y/canvas_data_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install canvas_data_client

## Usage

The client can be initialized as such:

```ruby
client = CanvasDataClient::Client.new(api_key, api_secret)
```

As much as possible, the methods available in the client match those given in the [API docs](https://portal.inshosteddata.com/docs/api)

List of methods:

```ruby
client.latest_files # GET /api/account/(:accountId|self)/file/latest
client.dumps # GET /api/account/(:accountId|self)/dump
client.dump # GET /api/account/(:accountId|self)/file/byDump/:dumpId
client.tables('course_dim') # GET /api/account/(:accountId|self)/file/byTable/:tableName
client.schemas # GET /api/schema
client.latest_schema # GET /api/schema/latest
client.schema('1.0.0') # GET /api/schema/:version
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ben-y/canvas_data_client.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
