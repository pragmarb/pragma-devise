# Pragma::Devise

[![Build Status](https://img.shields.io/travis/pragmarb/pragma-devise.svg?maxAge=3600&style=flat-square)](https://travis-ci.org/pragmarb/pragma-devise)
[![Dependency Status](https://img.shields.io/gemnasium/pragmarb/pragma-devise.svg?maxAge=3600&style=flat-square)](https://gemnasium.com/github.com/pragmarb/pragma-devise)
[![Code Climate](https://img.shields.io/codeclimate/github/pragmarb/pragma-devise.svg?maxAge=3600&style=flat-square)](https://codeclimate.com/github/pragmarb/pragma-devise)
[![Coveralls](https://img.shields.io/coveralls/pragmarb/pragma-devise.svg?maxAge=3600&style=flat-square)](https://coveralls.io/github/pragmarb/pragma-devise)

**DEPRECATED: Pragma::Devise has been deprecated in favor of more lightweight authentication schemes.**

Provides [Devise](https://github.com/plataformatec/devise) integration with
the [Pragma](https://github.com/pragmarb/pragma) architecture.

It gives you Pragma resources for Devise::Registerable, Devise::Confirmable and Devise::Recoverable.

It also adds [JWT](https://jwt.io) support to your application through the
[Knock](https://github.com/nsarno/knock) gem.

## Installation

### Devise

Add this line to your application's Gemfile:

```ruby
gem 'devise'
```

Next, follow the [Devise installation instructions](https://github.com/plataformatec/devise), but
make sure to skip the generation of any routes:

```ruby
devise_for :users, skip: :all
```

**NOTE:** By default, Devise will try to link to your backend for the confirmation and password
reset pages. Since we have skipped the generation of all routes, this means that the mailers will
crash. What you should do instead is create your own mailer views (you can edit the ones generated
by `rails g devise:views`) and link to URLs on your frontend instead. These URLs will call the
backend and complete the user confirmation and password reset processes.

### Knock

Add this line to your application's Gemfile (the fork is required until Knock approves
[our PR](https://github.com/nsarno/knock/pull/133)):

```ruby
gem 'knock', github: 'alessandro1997/knock', branch: 'specific-rescue'
```

Next, follow the [Knock installation instructions](https://github.com/plataformatec/devise). You
don't need to include `Knock::Authenticable` in your controller: it will be done for you by the
engine.

You should also override `current_user` in your base controller, e.g.:

```ruby
class ApplicationController < ActionController::Base
  def current_user
    pragma_devise_authenticate User
  end
end
```

This is needed because the gem does not know how you're going to authenticate your users from the
JWT.

### Pragma::Devise

Add this line to your application's Gemfile:

```ruby
gem 'pragma-devise'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install pragma-devise
```

If you want to override any of the gem's defaults, you can change them by creating an initializer
(e.g. `config/initializers/pragma_devise.rb`). Here are the defaults:

```ruby
Pragma::Devise.configure do |config|
  config.base_controller = '::ApplicationController'
end
```

## Creating operations

Pragma::Devise provides the following operations:

| Resource | Operations |
| -------- | ---------- |
| [Token](https://github.com/pragmarb/pragma-devise/tree/master/app/resources/pragma/devise/token) | Create |
| [User](https://github.com/pragmarb/pragma-devise/tree/master/app/resources/pragma/devise/user) | Index, Show, Create, Update, Destroy |
| [Confirmation](https://github.com/pragmarb/pragma-devise/tree/master/app/resources/pragma/devise/confirmation) | Create, Update |
| [Recovery](https://github.com/pragmarb/pragma-devise/tree/master/app/resources/pragma/devise/recovery) | Create, Update |

To use any of them, simply inherit from the Pragma::Devise operation in your own app, e.g.:

```ruby
module API
  module V1
    module User
      module Operation
        class Create < Pragma::Devise::User::Operation::Create
        end
      end
    end
  end
end
```

Then create a resource controller:

```ruby
module API
  module V1
    class UsersController < ApplicationController
      include Pragma::Rails::ResourceController
    end
  end
end
```

And finally, route to your new operation:

```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i(create)
    end
  end
end
```

This will create a signup endpoint at `POST /api/v1/users`.

If you want to override the policy, decorator or contract used by the operation, you can simply
create the relevant classes and Pragma will pick them up automatically.

While this inheritance model is a bit more complex to set up, it provides maximum flexibility and
also allows you to have multiple authenticating models at the same time.

## Authenticating users

After you have configured the gem, you can authenticate users by including
`Pragma::Devise::Operation::Authenticable` in your operations and installing the
`#authenticate_user` before hook, which will try to authenticate or respond with 401 Unauthorized
and an error payload:

```ruby
module API
  module V1
    module Post
      module Operation
        class Create < Pragma::Operation::Create
          include Pragma::Devise::Authenticable
          before :authenticate_user
        end
      end
    end
  end
end
```

If you want to customize how you respond, you can make your own hook with the help of
`#current_user` (which is what `#authenticate_user` uses under the hood):

```ruby
module API
  module V1
    module Post
      module Operation
        class Create < Pragma::Operation::Create
          include Pragma::Devise::Authenticable
          before :custom_authenticate_user

          private

          def custom_authenticate_user
            head! :unauthorized unless current_user
          end
        end
      end
    end
  end
end
```

## Testing

Test helpers are provided to easily authenticate in tests. To use them, include
`Pragma::Devise::Test::Helper` in your RSpec configuration:

```ruby
RSpec.configure do |config|
  config.include Pragma::Devise::Test::Helper
end
```

Now you can use the `#authenticate_as` helper to authenticate in tests:

```ruby
RSpec.describe '/api/v1/posts' do
  let(:current_user) { create(:user) }
  before { authenticate_as current_user }

  # ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pragmarb/pragma-devise.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
