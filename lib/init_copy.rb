# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020 Bradley Whited
#
# SPDX-License-Identifier: MIT
#++

require 'init_copy/version'

# Example usage:
#   require 'init_copy'
#
#   class JangoFett
#     include InitCopy::Able
#
#     protected
#
#     def init_copy(_orig)
#       super
#
#       @gear = ic_copy(@gear)
#       @order66 = ic_copy?(@order66) # Safe copy if no dup/clone.
#     end
#   end
module InitCopy
  module Able
    def initialize_clone(orig)
      super

      # The instance var name is long & obnoxious to reduce conflicts.
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
