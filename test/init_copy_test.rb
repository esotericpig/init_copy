# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: MIT
#++


require 'minitest/autorun'

require 'init_copy'


class Animal
  @@copy_name = nil

  attr_reader :name
  attr_reader :safe_name

  def copy_name
    return @@copy_name
  end
end

# For testing InitCopy.new() Copier.
class Cat < Animal
  def initialize
    super

    @name = 'Bunji'.dup
    @safe_name = 'Chino'.dup
  end

  def initialize_copy(orig)
    super(orig)

    ic = InitCopy.new

    @@copy_name = ic.name
    @name = ic.copy(@name)
    @safe_name = ic.safe_copy(@safe_name)
  end
end

# For testing Copyable.
class Dog < Animal
  include InitCopy::Copyable

  def initialize
    super

    @name = 'Lena'.dup
    @safe_name = 'Trooper'.dup
  end

  def initialize_copy(orig)
    super(orig)

    @@copy_name = @init_copy_method_name
    @name = copy(@name)
    @safe_name = safe_copy(@safe_name)
  end

  def init_copy_method_name
    return @init_copy_method_name
  end
end

# For testing clone() vs dup().
class Catdog < Animal
  def initialize
    super

    @name = 'Tiger'.dup
    @safe_name = 'Angel'.dup
  end

  def initialize_copy(orig)
    super(orig)

    ic = InitCopy.new

    @@copy_name = ic.name
    @name = ic.copy(@name)
    @safe_name = ic.safe_copy(@safe_name)
  end
end

class InitCopyTest < Minitest::Test
  def setup
  end

  def test_top_module
    assert_equal InitCopy::DEFAULT_COPY_NAME,InitCopy.new.name
    assert_equal :butterfly,InitCopy.new(:butterfly).name
    assert_equal :butterfly,InitCopy.find_copy_name(:butterfly)
  end

  def test_copier_basics
    assert_equal InitCopy::Copier,InitCopy::Copyer
    assert_equal InitCopy::DEFAULT_COPY_NAME,InitCopy::Copier.new.name

    assert_equal :butterfly,InitCopy::Copier.new(:butterfly).default_name
    assert_equal :butterfly,InitCopy::Copier.new(:butterfly).name

    copier = InitCopy::Copier.new

    copier.default_name = :butterfly
    copier.name = :ladybug

    assert_equal :butterfly,copier.default_name
    assert_equal :ladybug,copier.name

    copier.update_name

    assert_equal :butterfly,copier.name
  end

  def test_copier_clone
    cat = Cat.new

    assert_equal cat.name,cat.clone.name
    assert_equal cat.safe_name,cat.clone.safe_name

    cat.clone.name << 'hax!'
    cat.clone.safe_name << 'hax!'

    assert_equal :clone,cat.copy_name
    assert_equal 'Bunji',cat.name
    assert_equal 'Chino',cat.safe_name
  end

  def test_copier_dup
    cat = Cat.new

    assert_equal cat.name,cat.dup.name
    assert_equal cat.safe_name,cat.dup.safe_name

    cat.dup.name << 'hehe'
    cat.dup.safe_name << 'hehe'

    assert_equal :dup,cat.copy_name
    assert_equal 'Bunji',cat.name
    assert_equal 'Chino',cat.safe_name
  end

  def test_copyable_basics
    assert_equal InitCopy::Copyable,InitCopy::Copiable
    assert_equal InitCopy::DEFAULT_COPY_NAME,Dog.new.init_copy_method_name
  end

  def test_copyable_clone
    dog = Dog.new

    assert_equal dog.name,dog.clone.name
    assert_equal dog.safe_name,dog.clone.safe_name

    dog.clone.name << 'hax!'
    dog.clone.safe_name << 'hax!'

    assert_equal :clone,dog.copy_name
    assert_equal 'Lena',dog.name
    assert_equal 'Trooper',dog.safe_name
  end

  def test_copyable_dup
    dog = Dog.new

    assert_equal dog.name,dog.dup.name
    assert_equal dog.safe_name,dog.dup.safe_name

    dog.dup.name << 'hehe'
    dog.dup.safe_name << 'hehe'

    assert_equal :dup,dog.copy_name
    assert_equal 'Lena',dog.name
    assert_equal 'Trooper',dog.safe_name
  end

  def test_clone_vs_dup
    catdog = Catdog.new

    class << catdog.name
      def give_treat
        return 'big tuna'
      end
    end
    class << catdog.safe_name
      def give_treat
        return 'hamburger'
      end
    end

    assert_equal 'big tuna',catdog.name.give_treat
    assert_equal 'hamburger',catdog.safe_name.give_treat

    cloned = catdog.clone

    assert_equal :clone,cloned.copy_name
    assert_equal 'Tiger',cloned.name
    assert_equal 'Angel',cloned.safe_name

    duped = catdog.dup

    assert_equal :dup,duped.copy_name
    assert_equal 'Tiger',duped.name
    assert_equal 'Angel',duped.safe_name

    # clone() should preserve give_treat().
    assert_respond_to cloned.name,:give_treat
    assert_respond_to cloned.safe_name,:give_treat
    assert_equal 'big tuna',cloned.name.give_treat
    assert_equal 'hamburger',cloned.safe_name.give_treat

    # dup() should NOT preserve give_treat().
    refute_respond_to duped.name,:give_treat
    refute_respond_to duped.safe_name,:give_treat
  end
end
