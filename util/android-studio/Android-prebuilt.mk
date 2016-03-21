#================================================================#
# Copyright (c) 2010-2011 Zipline Games, Inc.
# All Rights Reserved.
# http://getmoai.com
#================================================================#

	LOCAL_PATH := $(call my-dir)
	
	include $(CLEAR_VARS)
	
	MOAI_SDK_HOME	:= @MOAI_SDK_HOME@
	
	MY_ARM_MODE		:= arm
	MY_ARM_ARCH		:= armeabi-v7a arm64-v8a x86

	MY_LOCAL_CFLAGS		:=
	MY_INCLUDES			:=
	

	#----------------------------------------------------------------#
	# recursive wildcard function
	#----------------------------------------------------------------#

	rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2)$(filter $(subst *,%,$2),$d))



#================================================================#
# moai core
#================================================================#

	MY_HEADER_SEARCH_PATHS += $(MOAI_SDK_HOME)/src/zl-vfs
	MY_HEADER_SEARCH_PATHS += $(MOAI_SDK_HOME)
	MY_HEADER_SEARCH_PATHS += $(MOAI_SDK_HOME)/src
	MY_HEADER_SEARCH_PATHS += $(MOAI_SDK_HOME)/src/config-default


#================================================================#
# moai modules
#================================================================#

   include $(MOAI_SDK_HOME)/libmoai/jni/prebuiltcore.mk
   include $(MOAI_SDK_HOME)/libmoai/jni/prebuilt.mk


#================================================================#
# targets
#================================================================#

	include libraries.mk

