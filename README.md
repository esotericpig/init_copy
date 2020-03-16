# InitCopy

[![Gem Version](https://badge.fury.io/rb/init_copy.svg)](https://badge.fury.io/rb/init_copy)

[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/init_copy)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/init_copy.svg)](LICENSE.txt)

Easily use the appropriate method in `initialize_copy`, either `clone` or `dup`.

On the one hand, there is *Bob*. He likes to define his `initialize_copy` using `clone`:

```Ruby
class Bob
  attr_reader :name
  
  def initialize
    super
    
    @name = 'Bob'
  end
  
  def initialize_copy(orig)
    super(orig)
    
    @name = @name.clone # Use clone
  end
end
```

On the other hand, there is *Fred*. He likes to use `dup`:

```Ruby
class Fred
  attr_reader :name
  
  def initialize
    super
    
    @name = 'Fred'
  end
  
  def initialize_copy(orig)
    super(orig)
    
    @name = @name.dup # Use dup
  end
end
```

Who is right? Who is wrong? Both lead to unexpected behavior.

`clone` and `dup` have several differences, but as an example, one difference is copying over extensions. If a Rubyist uses `clone` or `dup` expecting the standard documented behavior, they'll be surprised.

Here, Bob gets surprised:

```Ruby
module BobExt
  def bob_rules
    "#{self} rules!"
  end
end

bob  = Bob.new
fred = Fred.new

bob.name.extend(BobExt)
fred.name.extend(BobExt)

bob  = bob.clone
fred = fred.clone

puts bob.name.bob_rules  # OK!
puts fred.name.bob_rules # Error! Even though clone() should preserve BobExt!
```

And here, Fred gets surprised:

```Ruby
module FredExt
  def to_s
    "Fred's password is 1234"
  end
end

bob  = Bob.new
fred = Fred.new

bob.name.extend(FredExt)
fred.name.extend(FredExt)

bob  = bob.dup
fred = fred.dup

puts bob.name.to_s  # What!? dup() should have removed FredExt!
puts fred.name.to_s # OK!
```

So there are several solutions. The obvious one is to define `initialize_clone` and `initialize_dup` and call the appropriate methods, but that means you have duplicate code doing basically the same thing! And leads to copy &amp; pasting as well as forgetting about one of the methods.

```Ruby
def initialize_clone(orig)
  super(orig)
  
  @name = @name.clone
  # 100 more lines...
end

def initialize_dup(orig)
  super(orig)
  
  @name = @name.dup
  # 100 more lines...
end
```

Marshalling also won't solve this, as it will produce the same result for both `clone` and `dup`, when they should be different (according to the standard documentation) as illustrated earlier with `BobExt` and `FredExt`.

Well, then along comes *George*. He's a pretty nice guy. He likes to do it this way:

```Ruby
def initialize_copy(orig)
  super(orig)
  
  copy = caller[0].include?('clone') ? :clone : :dup
  
  @name = @name.__send__(copy)
  # More lines...
end
```

Admittedly, it's pretty hacky, but that's basically what this Gem does.

For speed, there is also a mixin (doesn't check the `caller`).

See the [Using](#using) section for more info.

## Contents

- [Setup](#setup)
- [Using](#using)
- [Hacking](#hacking)
- [License](#license)

## [Setup](#contents)

Pick your poison...

In your *Gemspec* (*&lt;project&gt;.gemspec*):

```Ruby
# Pick one...
spec.add_runtime_dependency 'init_copy', '~> X.X.X'
spec.add_development_dependency 'init_copy', '~> X.X.X'
```

In your *Gemfile*:

```Ruby
# Pick one...
gem 'init_copy', '~> X.X.X'
gem 'init_copy', '~> X.X.X', :group => :development
gem 'init_copy', :git => 'https://github.com/esotericpig/init_copy.git', :tag => 'vX.X.X'
```

With the RubyGems CLI package manager:

`$ gem install init_copy`

Manually:

```
$ git clone 'https://github.com/esotericpig/init_copy.git'
$ cd init_copy
$ bundle install
$ bundle exec rake install:local
```

## [Using](#contents)

### With the Copier Class

```Ruby
require 'init_copy'

class George
  attr_reader :name
  attr_reader :cool
  
  def initialize
    super
    
    @name = 'George'.dup
    @cool = true
  end
  
  def initialize_copy(orig)
    super(orig)
    
    ic = InitCopy.new()
    
    @name = ic.copy(@name)
    @cool = ic.copy(@cool)
  end
end

og = George.new
ng = og.dup

ng.name << ' drools!'

puts og.name # "George"
```

In the constructor, you can set the default fallback to `:clone` instead (in case the `caller` cannot be determined):

```Ruby
ic = InitCopy.new(:clone) # Default (no args) is :dup
```

There is also a `safe_copy` in case the Object does not have a `clone` or `dup` method:

```Ruby
@name = ic.safe_copy(@name)
@cool = ic.safe_copy(@cool)
```

If you want to store the class in an instance variable for some reason (**not recommended**), you can call `update_name`:

```Ruby
class George
  attr_reader :name
  attr_reader :cool
  
  def initialize
    super
    
    @ic = InitCopy.new(:butterfly)
    
    @name = 'George'.dup
    @cool = true
  end
  
  def initialize_copy(orig)
    super(orig)
    
    puts "Copy method name: #{@ic.name}" # :butterfly
    @ic.update_name()
    puts "Copy method name: #{@ic.name}" # :clone or :dup
    
    @name = @ic.copy(@name)
    @cool = @ic.copy(@cool)
  end
end
```

Under the hood, this uses `InitCopy::Copier`, which also has an alias `InitCopy::Copyer`.

### With the Copyable Mixin

The mixin is faster than the above class way; because instead of relying on searching &amp; parsing the `caller`, it sets `@init_copy_method_name` to either `:clone` or `:dup` appropriately in the following methods that it defines:

- `initialize_clone`
- `initialize_dup`
- `clone`
- `dup`

Then in your `initialize_copy`, use one of these methods that it also defines:

- `copy`
- `safe_copy`

**Note**: If your class and/or its descendants redefine any of these methods, they must call `super`, else it will not work!

```Ruby
require 'init_copy'

class George
  include InitCopy::Copyable
  
  attr_reader :name
  attr_reader :cool
  
  def initialize
    super
    
    @name = 'George'.dup
    @cool = true
  end
  
  def initialize_copy(orig)
    super(orig)
    
    @name = copy(@name)
    @cool = safe_copy(@cool)
  end
end

og = George.new
ng = og.dup

ng.name << ' drools!'

puts og.name # "George"
```

You can set the default fallback in your constructor:

```Ruby
def initialize
  super
  
  @init_copy_method_name = :clone
end
```

**Note**: `@init_copy_method_name` could be `nil` in `copy` if `super` was not called in your `initialize` method, and this will cause an error. `safe_copy` checks for this scenario and will default to `:dup` if `nil`. In general, it should be safe to not define a default value, assuming correct coding practices.

`InitCopy::Copiable` is an alias to this class.

## [Hacking](#contents)

```
$ git clone 'https://github.com/esotericpig/init_copy.git'
$ cd init_copy
$ bundle install
$ bundle exec rake -T
```

### Testing

```
$ bundle exec rake test
```

### Generating Doc

```
$ bundle exec rake doc
```

## [License](#contents)

[MIT](LICENSE.txt)

> Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)  
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy  
> of this software and associated documentation files (the "Software"), to deal  
> in the Software without restriction, including without limitation the rights  
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
> copies of the Software, and to permit persons to whom the Software is  
> furnished to do so, subject to the following conditions:  
> 
> The above copyright notice and this permission notice shall be included in all  
> copies or substantial portions of the Software.  
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
> SOFTWARE.  
