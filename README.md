# InitCopy

[![Gem Version](https://badge.fury.io/rb/init_copy.svg)](https://badge.fury.io/rb/init_copy)

[![Source Code](https://img.shields.io/badge/source-github-%23A0522D.svg?style=for-the-badge)](https://github.com/esotericpig/init_copy)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg?style=for-the-badge)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/init_copy.svg?color=%23A0522D&style=for-the-badge)](LICENSE.txt)


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
