# ActiveGraphql

This gem provides ActiveRecord-style models for use with GraphQL APIs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_graphql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_graphql

## Usage

### Configuring the gem

This gem depends on the Oauth2Autorenew gem to handle the retrieval and renewal
of access tokens. This can be configured as follows:
```
require 'oauth2_autorenew/access_token'
require 'active_graphql'

oauth_opts = {
  client_id: 'my-client',
  client_secret: 'abcd1234-1234-abcd-1234-abcd1234abcd',
  expiry_message: 'Authentication failed',
  site_url: 'http://localhost:3000/api',
  token_url: 'http://localhost:3001/auth/realms/my-realm/protocol/openid-connect/token'
}

access_token = Oauth2Autorenew::AccessToken.new(
  logger: Logger.new($stdout),
  oauth_opts: oauth_opts
)

ActiveGraphql.configure(access_token)
```

### Creating model classes for use with an API
```
CREATE_MUTATION = <<~GRAPHQL
  mutation($input: CreateCompanyInput!) {
    createCompany(input: $input) {
      company {
        id
        name
        domainIdentifier
        securityDomain
        internal
        blueLight
        partner
      }
    }
  }
GRAPHQL

CREATE_VARIABLES = -> {
  {
    input: {
      domainIdentifier: domain_identifier,
      name: name,
      securityDomain: security_domain,
      internal: internal,
      blueLight: blue_light,
      partner: partner
    }
  }
}

UPDATE_MUTATION = <<~GRAPHQL
  mutation($input: UpdateCompanyInput!) {
    updateCompany(input: $input) {
      company {
        id
        name
        domainIdentifier
        securityDomain
        internal
        blueLight
        partner
      }
    }
  }
GRAPHQL

UPDATE_VARIABLES = -> {
  {
    input: {
      id: id,
      name: name,
      internal: internal,
      blueLight: blue_light,
      partner: partner
    }
  }
}


class Company < ActiveGraphql::BaseModel::Model
  attribute :id
  attribute :name
  attribute :domain_identifier
  attribute :security_domain
  attribute :internal
  attribute :blue_light
  attribute :partner

  set_create mutation: CREATE_MUTATION, variables: CREATE_VARIABLES
  set_update mutation: UPDATE_MUTATION, variables: UPDATE_VARIABLES
end
```

Attributes are defined similarly to ActiveModel in Rails.

The create and update mutations are provided as a string. A lambda is used to
generate the variables that are sent to GraphQL from the attributes of the
instance.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jimbali/active_graphql.
