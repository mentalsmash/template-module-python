################################################################################
# (C) Copyright 2020 Andrea Sorbini
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
#
# This makefile provides a target to customize the template.
# It should only be used on a new repository created from template:
# https://github.com/mentalsmash/template-python-module
#
# User must specify these variables:
#
# - MODULE: name of the module
#
# - AUTHOR: full name of the module's author/Copyright owner.
#
# - EMAIL: email contact for the module
#
# - DESCRIPTION: one-line description of the module.
#
# The following variables may be optionally specified, but will receive a
# default value otherwise:
#
# - YEAR: Year entry for Copyright header. Default: year reported by `date`.
#
# - VERSION: Initial version tag for the module. Default: 0.1.0
#
# - URL: Homepage for the module. Default: URL of git's `origin` remote.
#
# - PY_MIN: Minimum version of Python 3 supported by the module. Default: 3.6
#
################################################################################
# Check that all required variables have been specified
################################################################################
ifeq ($(MODULE),)
$(error no MODULE specified)
endif
ifeq ($(AUTHOR),)
$(error no AUTHOR specified)
endif
ifeq ($(EMAIL),)
$(error no EMAIL specified)
endif
ifeq ($(DESCRIPTION),)
$(error no DESCRIPTION specified)
endif
################################################################################
# Set optional variables
################################################################################
YEAR ?= $(shell date +%Y)
VERSION ?= 0.1.0
URL ?= $(shell git remote get-url origin)
PY_MIN ?= 3.6
################################################################################
# Files to check to verify the template's integrity
################################################################################
TEMPLATE_FILES := Makefile \
                  template-init.mk \
                  README.md \
                  README.template.md \
                  LICENSE \
                  VERSION \
                  setup.py \
                  requirements.txt \
                  .gitignore \
                  my_module/__init__.py

TEMPLATE_DIRS := .git \
                  my_module

define TEMPLATE_VERIFY
for f in $(1); do \
	if [ ! -f "$${f}" ]; then \
		echo "-- Required file not found: $${f}" >&2; \
		[ -n "$(TEMPLATE_DEV)" ] || exit 1; \
	fi; \
done; \
for d in $(2); do \
	if [ ! -d "$${d}" ]; then \
		echo "-- Required directory not found: $${d}" >&2; \
		[ -n "$(TEMPLATE_DEV)" ] || exit 1; \
	fi; \
done
endef


define TEMPLATE_REPLACE_A
find . ! -path "*.git*" -type f -exec sed -i 's/$(1)/$(2)/g' {} \;
endef

define TEMPLATE_REPLACE
$(call TEMPLATE_REPLACE_A,$(1),$($(1)))
endef

################################################################################
# Template initialization target
################################################################################
template-init:
	$(call TEMPLATE_VERIFY, $(TEMPLATE_FILES), $(TEMPLATE_DIRS))
	$(call TEMPLATE_REPLACE_A,my_module,$(MODULE))
	$(call TEMPLATE_REPLACE,AUTHOR)
	$(call TEMPLATE_REPLACE,EMAIL)
	$(call TEMPLATE_REPLACE,DESCRIPTION)
	$(call TEMPLATE_REPLACE,YEAR)
	# $(call TEMPLATE_REPLACE,URL)
	$(call TEMPLATE_REPLACE,VERSION)
	$(call TEMPLATE_REPLACE,PY_MIN)
	mv my_module $(MODULE)
	rm README.template.md
	rm template-init.mk
	sed -ir 's/^include template-init.mk$$//' Makefile
	sed -ir 's/^# //' Makefile
	@echo The repository has been initialized for module \'$(MODULE)\'. Now you can:
	@echo -e - Inspect the results, and commit changes with:'\n\t'git add -A && git commit
	@echo -e - Revert all changes and start again with:'\n\t'git reset --hard
