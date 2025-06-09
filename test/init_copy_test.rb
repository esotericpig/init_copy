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

describe InitCopy do
  it 'has a correct version' do
    _(InitCopy::VERSION).must_match(/\d+\.\d+\.\d+(-[0-9A-Za-z\-.]+)?(\+[0-9A-Za-z\-.]+)?/)
  end

  def self.add_basic_copy_tests
    it 'is not the same as the copies' do
      _(@sut).wont_be_same_as(@sut_clone)
      _(@sut).wont_be_same_as(@sut_dup)
    end

    it 'has the correct copy method name' do
      _(@sut.init_copy_method_name).must_be_nil
      _(@sut_clone.init_copy_method_name).must_equal(:clone)
      _(@sut_dup.init_copy_method_name).must_equal(:dup)
    end
  end

  def self.add_deep_copy_tests(is_frozen: false)
    it 'has the correct original' do
      _(@sut.orig).must_be_nil
      _(@sut_clone.orig).must_be_same_as(@sut)
      _(@sut_dup.orig).must_be_same_as(@sut)
    end

    it 'does a deep copy' do
      _(@sut.nums).wont_be_same_as(@sut_clone.nums)
      _(@sut.nums).wont_be_same_as(@sut_dup.nums)

      expected = [1,2,3]

      _(@sut.nums).must_equal(expected)
      _(@sut_clone.nums).must_equal(expected)
      _(@sut_dup.nums).must_equal(expected)

      if !is_frozen
        @sut.nums << 4
        @sut_clone.nums << 5
        @sut_dup.nums << 6

        _(@sut.nums).must_equal([1,2,3,4])
        _(@sut_clone.nums).must_equal([1,2,3,5])
        _(@sut_dup.nums).must_equal([1,2,3,6])
      end
    end
  end

  describe 'without copy' do
    before do
      @sut = TestBag.new
      @sut_clone = @sut.clone
      @sut_dup = @sut.dup
    end

    add_basic_copy_tests

    it 'has no original' do
      _(@sut.orig).must_be_nil
      _(@sut_clone.orig).must_be_nil
      _(@sut_dup.orig).must_be_nil
    end

    it 'does not do a deep copy' do
      _(@sut.nums).must_be_same_as(@sut_clone.nums)
      _(@sut.nums).must_be_same_as(@sut_dup.nums)

      expected = [1,2,3]

      _(@sut.nums).must_equal(expected)
      _(@sut_clone.nums).must_equal(expected)
      _(@sut_dup.nums).must_equal(expected)

      @sut.nums << 4
      @sut_clone.nums << 5
      @sut_dup.nums << 6

      expected = [1,2,3,4,5,6]

      _(@sut.nums).must_equal(expected)
      _(@sut_clone.nums).must_equal(expected)
      _(@sut_dup.nums).must_equal(expected)
    end
  end

  describe 'with copy' do
    before do
      @sut = TestBagWithCopy.new
      @sut_clone = @sut.clone
      @sut_dup = @sut.dup
    end

    add_basic_copy_tests
    add_deep_copy_tests
  end

  describe 'with copy and internal state' do
    before do
      @sut = TestBagWithCopy.new

      @sut.nums.extend(
        Module.new do
          def bonus
            return 110
          end
        end
      )
      @sut.nums.freeze

      @sut_clone = @sut.clone
      @sut_dup = @sut.dup
    end

    add_basic_copy_tests
    add_deep_copy_tests(is_frozen: true)

    it 'has the correct bonus extension' do
      _(@sut.nums).must_respond_to(:bonus,'SUT should have the nums bonus extension')
      _(@sut.nums.bonus).must_equal(110)

      _(@sut_clone.nums).must_respond_to(:bonus,'clone should keep the nums bonus extension')
      _(@sut_clone.nums.bonus).must_equal(110)

      _(@sut_dup.nums).wont_respond_to(:bonus,'dup should remove the nums bonus extension')
      _ { @sut_dup.bonus }.must_raise(NoMethodError)
    end

    it 'has the correct frozen state' do
      _(@sut.nums.frozen?).must_equal(true,'SUT should have the nums as frozen')
      _(@sut_clone.nums.frozen?).must_equal(true,'clone should keep the nums as frozen')
      _(@sut_dup.nums.frozen?).must_equal(false,'dup should remove the nums as frozen')
    end
  end

  describe 'child with copy and unsafe var' do
    before do
      @sut = TestBagChildWithCopyAndUnsafe.new
      @sut_clone = @sut.clone
      @sut_dup = @sut.dup
    end

    add_basic_copy_tests
    add_deep_copy_tests

    it 'does a deep copy of the strs' do
      _(@sut.strs).wont_be_same_as(@sut_clone.strs)
      _(@sut.strs).wont_be_same_as(@sut_dup.strs)

      expected = %w[a b c]

      _(@sut.strs).must_equal(expected)
      _(@sut_clone.strs).must_equal(expected)
      _(@sut_dup.strs).must_equal(expected)

      @sut.strs << 'd'
      @sut_clone.strs << 'e'
      @sut_dup.strs << 'f'

      _(@sut.strs).must_equal(%w[a b c d])
      _(@sut_clone.strs).must_equal(%w[a b c e])
      _(@sut_dup.strs).must_equal(%w[a b c f])
    end

    it 'does not do a deep copy of the unsafe var' do
      _(@sut.unsafe).wont_respond_to(:clone)
      _(@sut.unsafe).wont_respond_to(:dup)

      _(@sut.unsafe).must_be_same_as(@sut_clone.unsafe)
      _(@sut.unsafe).must_be_same_as(@sut_dup.unsafe)
    end
  end
end

class TestBag
  include InitCopy::Able

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

class TestBagChildWithCopyAndUnsafe < TestBagWithCopy
  attr_reader :strs
  attr_reader :unsafe

  def initialize
    super

    @strs = %w[a b c]
    @unsafe = Class.new do
      undef_method :clone
      undef_method :dup
    end.new
  end

  def init_copy(*)
    super

    @strs = ic_copy(@strs)
    @unsafe = ic_copy?(@unsafe)
  end
end
