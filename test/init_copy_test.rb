#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)
# 
# InitCopy is free software: you can redistribute it and/or modify it under
# the terms of the MIT License.
# 
# You should have received a copy of the MIT License along with InitCopy.
# If not, see <https://choosealicense.com/licenses/mit/>.
#++


require 'minitest/autorun'

require 'init_copy'


class Animal
  @@copy_name = nil
  
  attr_reader :name
  attr_reader :safe_name
  
  def copy_name()
    return @@copy_name
  end
end

class Cat < Animal
  def initialize()
    @name = 'Bunji'.dup()
    @safe_name = 'Chino'.dup()
  end
  
  def initialize_copy(orig)
    super(orig)
    
    ic = InitCopy.new()
    
    @@copy_name = ic.name
    @name = ic.copy(@name)
    @safe_name = ic.safe_copy(@safe_name)
  end
end

class Dog < Animal
  include InitCopy::Copyable
  
  def initialize()
    @name = 'Lena'.dup()
    @safe_name = 'Trooper'.dup()
  end
  
  def initialize_copy(orig)
    super(orig)
    
    @@copy_name = @init_copy_method_name
    @name = copy(@name)
    @safe_name = safe_copy(@safe_name)
  end
end

class InitCopyTest < Minitest::Test
  def setup()
  end
  
  def test_top_module()
    assert_equal InitCopy::DEFAULT_COPY_NAME,InitCopy.new().name
    assert_equal :butterfly,InitCopy.new(:butterfly).name
    assert_equal :butterfly,InitCopy.find_copy_name(:butterfly)
  end
  
  def test_copier_basics()
    assert_equal InitCopy::Copier,InitCopy::Copyer
    assert_equal InitCopy::DEFAULT_COPY_NAME,InitCopy::Copier.new().name
    assert_equal :butterfly,InitCopy::Copier.new(:butterfly).default_name
    assert_equal :butterfly,InitCopy::Copier.new(:butterfly).name
    
    copier = InitCopy::Copier.new()
    
    copier.default_name = :butterfly
    copier.name = :ladybug
    
    assert_equal :butterfly,copier.default_name
    assert_equal :ladybug,copier.name
    
    copier.update_name()
    
    assert_equal :butterfly,copier.name
  end
  
  def test_copier_clone()
    cat = Cat.new()
    
    assert_equal cat.name,cat.clone().name
    assert_equal cat.safe_name,cat.clone().safe_name
    
    cat.clone().name << 'hax!'
    cat.clone().safe_name << 'hax!'
    
    assert_equal :clone,cat.copy_name
    assert_equal 'Bunji',cat.name
    assert_equal 'Chino',cat.safe_name
  end
  
  def test_copier_dup()
    cat = Cat.new()
    
    assert_equal cat.name,cat.dup().name
    assert_equal cat.safe_name,cat.dup().safe_name
    
    cat.dup().name << 'hehe'
    cat.dup().safe_name << 'hehe'
    
    assert_equal :dup,cat.copy_name
    assert_equal 'Bunji',cat.name
    assert_equal 'Chino',cat.safe_name
  end
  
  def test_copyable_basics()
    assert_equal InitCopy::Copyable,InitCopy::Copiable
  end
  
  def test_copyable_clone()
    dog = Dog.new()
    
    assert_equal dog.name,dog.clone().name
    assert_equal dog.safe_name,dog.clone().safe_name
    
    dog.clone().name << 'hax!'
    dog.clone().safe_name << 'hax!'
    
    assert_equal :clone,dog.copy_name
    assert_equal 'Lena',dog.name
    assert_equal 'Trooper',dog.safe_name
  end
  
  def test_copyable_dup()
    dog = Dog.new()
    
    assert_equal dog.name,dog.dup().name
    assert_equal dog.safe_name,dog.dup().safe_name
    
    dog.dup().name << 'hehe'
    dog.dup().safe_name << 'hehe'
    
    assert_equal :dup,dog.copy_name
    assert_equal 'Lena',dog.name
    assert_equal 'Trooper',dog.safe_name
  end
end
