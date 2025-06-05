# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020 Bradley Whited
#
# SPDX-License-Identifier: MIT
#++

require 'minitest/autorun'

require 'init_copy'

class InitCopyTest < Minitest::Test
  # def setup
  # end

  def test_include
    %i[include extend prepend].each do |method|
      sut_class = Class.new
      sut_class.__send__(method,InitCopy)

      assert_includes(sut_class.included_modules,InitCopy::Copyable,
                      "`#{method}` of InitCopy should include InitCopy::Copyable")
    end
  end

  def test_no_copy
    sut = TestBag.new

    refute_deep_copy(sut,sut.clone,:clone)
    refute_deep_copy(sut,sut.dup,:dup)
  end

  def test_clone
    sut = TestBagWithCopy.new

    assert_deep_copy(sut,sut.clone,:clone)
  end

  def test_dup
    sut = TestBagWithCopy.new

    assert_deep_copy(sut,sut.dup,:dup)
  end

  def test_correct_clone_and_dup_behavior
    sut_ext = Module.new do
      def bonus
        return 100
      end
    end

    sut = TestBagWithCopy.new
    sut.extend(sut_ext)

    assert_deep_copy(sut,sut.clone,:clone)
    assert_deep_copy(sut,sut.dup,:dup)

    sut.nums.freeze
    sut_clone = sut.clone
    sut_dup = sut.dup

    assert_predicate(sut.nums,:frozen?,'SUT nums should be frozen')
    assert_respond_to(sut,:bonus,'SUT should have the bonus extension')
    assert_equal(100,sut.bonus)

    assert_predicate(sut_clone.nums,:frozen?,'clone should keep the nums as frozen')
    assert_respond_to(sut_clone,:bonus,'clone should keep the bonus extension')
    assert_equal(100,sut_clone.bonus)

    refute_predicate(sut_dup.nums,:frozen?,'dup should remove the internal frozen state of nums')
    refute_respond_to(sut_dup,:bonus,'dup should remove the bonus extension')
    assert_raises(NoMethodError) { sut_dup.bonus }
  end

  def test_safe_copy
    sut = TestBagWithSafeCopy.new

    assert_respond_to(sut.nums,:clone)
    assert_respond_to(sut.nums,:dup)

    assert_deep_copy(sut,sut.clone,:clone)
    assert_deep_copy(sut,sut.dup,:dup)

    class << sut.nums
      undef_method :clone
      undef_method :dup
    end

    refute_respond_to(sut.nums,:clone)
    refute_respond_to(sut.nums,:dup)

    refute_deep_copy(sut,sut.clone,:clone,is_safe_copy: true)
    refute_deep_copy(sut,sut.dup,:dup,is_safe_copy: true)

    # Make sure we didn't remove clone()/dup() for all arrays.
    assert_respond_to([1,2,3],:clone)
    assert_respond_to([1,2,3],:dup)
  end

  def test_child_copy
    sut_class = Class.new(TestBagWithCopy) do
      attr_reader :strs

      def initialize
        super

        @strs = %w[a b c]
      end

      def init_copy(*)
        super

        @strs = ic_copy(@strs)
      end
    end

    sut = sut_class.new
    sut_clone = sut.clone
    sut_dup = sut.dup

    assert_deep_copy(sut,sut_clone,:clone)
    assert_deep_copy(sut,sut_dup,:dup)

    expected = %w[a b c]

    refute_same(sut.strs,sut_clone.strs)
    refute_same(sut.strs,sut_dup.strs)
    assert_equal(expected,sut.strs)
    assert_equal(expected,sut_clone.strs)
    assert_equal(expected,sut_dup.strs)

    sut.strs << 'd'
    sut_clone.strs << 'e'
    sut_dup.strs << 'f'

    assert_equal(%w[a b c d],sut.strs)
    assert_equal(%w[a b c e],sut_clone.strs)
    assert_equal(%w[a b c f],sut_dup.strs)
  end

  def assert_deep_copy(sut,sut_copy,copy_method_name)
    refute_same(sut,sut_copy)

    assert_nil(sut.init_copy_method_name)
    assert_equal(copy_method_name,sut_copy.init_copy_method_name)

    assert_nil(sut.orig)
    assert_same(sut,sut_copy.orig)

    expected = [1,2,3]

    refute_same(sut.nums,sut_copy.nums)
    assert_equal(expected,sut.nums)
    assert_equal(expected,sut_copy.nums)

    sut.nums << 4
    sut_copy.nums << 5

    assert_equal([1,2,3,4],sut.nums)
    assert_equal([1,2,3,5],sut_copy.nums)

    # Reset.
    sut.nums.pop
    sut_copy.nums.pop
  end

  def refute_deep_copy(sut,sut_copy,copy_method_name,is_safe_copy: false)
    refute_same(sut,sut_copy)

    assert_nil(sut.init_copy_method_name)
    assert_equal(copy_method_name,sut_copy.init_copy_method_name)

    assert_nil(sut.orig)

    if is_safe_copy
      assert_same(sut,sut_copy.orig)
    else
      assert_nil(sut_copy.orig)
    end

    expected = [1,2,3]

    assert_same(sut.nums,sut_copy.nums)
    assert_equal(expected,sut.nums)
    assert_equal(expected,sut_copy.nums)

    sut.nums << 4
    sut_copy.nums << 5

    expected = [1,2,3,4,5]

    assert_equal(expected,sut.nums)
    assert_equal(expected,sut_copy.nums)

    # Reset.
    sut.nums.pop(2)
  end
end

class TestBag
  include InitCopy

  attr_reader :orig
  attr_reader :nums

  def initialize
    super

    @__init_copy_method_name = nil
    @orig = nil
    @nums = [1,2,3]
  end

  def init_copy_method_name
    return @__init_copy_method_name
  end
end

class TestBagWithCopy < TestBag
  protected

  def init_copy(orig)
    super

    @orig = orig
    @nums = ic_copy(@nums)
  end
end

class TestBagWithSafeCopy < TestBag
  protected

  def init_copy(orig)
    super

    @orig = orig
    @nums = ic_copy?(@nums)
  end
end
