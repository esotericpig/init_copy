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


###
# @author Jonathan Bradley Whited (@esotericpig)
# @since  0.1.0
###
module InitCopy
  VERSION = '0.1.0'
  
  DEFAULT_COPY_NAME=:dup
  
  def self.new(default_name=DEFAULT_COPY_NAME)
    return Copier.new(default_name)
  end
  
  def self.find_copy_name(default_name=DEFAULT_COPY_NAME)
    copy_name = default_name
    
    caller.each() do |name|
      if name.end_with?(%q(clone'))
        copy_name = :clone
        break
      end
      
      if name.end_with?(%q(dup'))
        copy_name = :dup
        break
      end
    end
    
    return copy_name
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class Copier
    attr_accessor :default_name
    attr_accessor :name
    
    def initialize(default_name=DEFAULT_COPY_NAME)
      super()
      
      @default_name = default_name
      
      update_name()
    end
    
    def copy(var)
      return var.__send__(@name)
    end
    
    def safe_copy(var)
      return var.respond_to?(@name) ? var.__send__(@name) : var
    end
    
    def update_name()
      @name = InitCopy.find_copy_name(@default_name)
    end
  end
  
  Copyer = Copier # Alias
  
  ###
  # The instance variable name is long and obnoxious to reduce conflicts.
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  module Copyable
    def initialize_clone(*)
      @init_copy_method_name = :clone
      super
    end
    
    def initialize_dup(*)
      @init_copy_method_name = :dup
      super
    end
    
    def clone(*)
      @init_copy_method_name = :clone
      super
    end
    
    def dup(*)
      @init_copy_method_name = :dup
      super
    end
    
    private
    
    def copy(var)
      return var.__send__(@init_copy_method_name)
    end
    
    def safe_copy(var)
      @init_copy_method_name = DEFAULT_COPY_NAME if @init_copy_method_name.nil?()
      
      return var.respond_to?(@init_copy_method_name) ?
        var.__send__(@init_copy_method_name) : var
    end
  end
  
  Copiable = Copyable # Alias
end