# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020 Bradley Whited
#
# SPDX-License-Identifier: MIT
#++

module InitCopy
  VERSION = '0.2.0'

  def self.included(mod)
    super

    # NOTE: Can't use prepend(), else children's init_copy() won't call their parents', even with super().
    mod.include(Copyable)
  end

  def self.extended(mod)
    super

    mod.include(Copyable)
  end

  def self.prepended(mod)
    super

    # User specifically requested to prepend.
    mod.prepend(Copyable)
  end

  module Copyable
    def initialize_clone(orig)
      super

      # The instance variable name is long & obnoxious to reduce conflicts.
      @__init_copy_method_name = :clone
      init_copy(orig)
    end

    def initialize_dup(orig)
      super

      @__init_copy_method_name = :dup
      init_copy(orig)
    end

    protected

    def init_copy(_orig)
    end

    def ic_copy(var)
      return var.__send__(@__init_copy_method_name)
    end

    def ic_copy?(var)
      return var.__send__(@__init_copy_method_name) if var.respond_to?(@__init_copy_method_name)
      return var
    end
  end
end
