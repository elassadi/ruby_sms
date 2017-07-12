# ruby_sms
simple way to send sms using sms77 or any other short message api provider  
A Ruby client library for [Sms77][more to come].

**You will need a valid account with an api key to access the api endpoints**


## Getting started

To install **ruby_sms**, run the following command:

```
  gem install ruby_sms
```

Or if you are using **bundler**, add

```
  gem 'ruby-sms', '~>1.0'
```

to your `Gemfile`, and run `bundle install`

```ruby
require "ruby_sms"
sms = RubySms.new(api_key: "1234123", user: "user@email.com")
response = sms.send(message: "your message", to: "+49178223", delay: false)
if response.success? 
  puts "Sms deliverd " 
else
  puts response.errors
end
```
