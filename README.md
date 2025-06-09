# InitCopy

[![Gem Version](https://badge.fury.io/rb/init_copy.svg)](https://badge.fury.io/rb/init_copy)
[![CI Status](https://github.com/esotericpig/init_copy/actions/workflows/ci.yml/badge.svg)](https://github.com/esotericpig/init_copy/actions/workflows/ci.yml)
[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/init_copy)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/init_copy.svg)](LICENSE.txt)

🧬 Easily use the correct `clone` or `dup` method in `initialize_copy`.

If we only use either `clone` or `dup` or we use `Marshal`, then that does not produce the correct behavior according to the [standard documentation](https://docs.ruby-lang.org/en/master/Object.html#method-i-dup-label-on+dup+vs+clone). This is because `clone` should preserve the internal state (e.g., the frozen state and extended modules), while `dup` should not. For example:

```ruby
module SecretExt
  def secret
    'password'
  end
end

# Init vars.
bob = 'Bob'
bob.extend(SecretExt)
bob.freeze

clone = bob.clone
dup   = bob.dup

# Check vars.
puts clone.frozen? #=> true
puts dup.frozen?   #=> false

puts clone.secret  #=> password
puts dup.secret    #=> NoMethodError
```

To solve this issue in the past, we had to define both `initialize_clone` & `initialize_dup` and maintain two copies of all our deep-copy code. That sucks. 😞

🚀 Instead, *InitCopy* was created:

1. Install the gem `init_copy` ([on RubyGems.org](https://rubygems.org/gems/init_copy)).
2. Include `InitCopy::Able` in your class/module.
3. Override the `init_copy(original)` method.
4. Use `ic_copy(var)`, instead of clone/dup.

Example usage:

```ruby
require 'init_copy'

class JangoFett
  include InitCopy::Able

  attr_reader :gear,:bounties,:order66

  def initialize
    super

    @gear = ['blaster','jetpack']
    @bounties = ['Padmé','Vosa']

    @order66 = Class.new do
      undef_method :clone
      undef_method :dup
    end.new
  end

  protected

  def init_copy(_orig)
    super

    @gear = ic_copy(@gear)
    @bounties = ic_copy(@bounties)

    @order66 = ic_copy?(@order66) # Safe copy if no dup/clone.
  end
end

# Init vars.
jango = JangoFett.new
jango.bounties.freeze

boba1 = jango.clone
boba2 = jango.dup

jango.gear << 'vibroblade'
boba1.gear << 'implant'

# Check vars.
puts jango.gear.inspect     #=> ["blaster", "jetpack", "vibroblade"]

puts boba1.gear.inspect     #=> ["blaster", "jetpack", "implant"]
puts boba2.gear.inspect     #=> ["blaster", "jetpack"]

puts boba1.bounties.inspect #=> ["Padmé", "Vosa"]
puts boba2.bounties.inspect #=> ["Padmé", "Vosa"]

puts boba1.bounties.frozen? #=> true  (clone)
puts boba2.bounties.frozen? #=> false (dup)
```

## // Contents

- [Setup](#-setup)
- [Hacking](#-hacking)
- [License](#-license)

## [//](#-contents) Setup

Pick your poison...

With the *RubyGems* CLI package manager:

```bash
gem install init_copy
```

In your *Gemspec*:

```ruby
spec.add_dependency 'init_copy', '~> X.X'
```

In your *Gemfile*:

```ruby
# Pick your poison...
gem 'init_copy', '~> X.X'
gem 'init_copy', git: 'https://github.com/esotericpig/init_copy.git', branch: 'main'
```

From source:

```bash
git clone --depth 1 'https://github.com/esotericpig/init_copy.git'
cd init_copy
bundle install
bundle exec rake install:local
```

## [//](#-contents) Hacking

```bash
git clone 'https://github.com/esotericpig/init_copy.git'
cd init_copy
bundle install
bundle exec rake -T
```

Testing:

```bash
bundle exec rake test
```

Generating doc:

```bash
bundle exec rake clobber_doc doc
```

Installing:

```bash
bundle exec rake install:local
```

## [//](#-contents) License

Copyright (c) 2020-2025 Bradley Whited  
[MIT License](LICENSE.txt)  
