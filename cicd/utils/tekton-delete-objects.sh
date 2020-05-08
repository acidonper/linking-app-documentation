#!/bin/sh
##
# Script to clean principal objects in tekton through tkn client
##

tkn eventlistener list | grep -v NAME | awk '{print "tkn eventlistener delete "$1 " -f"}'| sh
tkn triggerbinding list | grep -v NAME | awk '{print "tkn triggerbinding delete "$1 " -f"}'| sh
tkn triggertemplate list | grep -v NAME | awk '{print "tkn triggertemplate delete "$1 " -f"}'| sh
tkn pipelinerun list | grep -v NAME | awk '{print "tkn pipelinerun delete "$1 " -f"}'| sh
tkn pipeline list | grep -v NAME | awk '{print "tkn pipeline delete "$1 " -f"}'| sh
tkn task list | grep -v NAME | awk '{print "tkn task delete "$1 " -f"}'| sh
tkn resource list | grep -v NAME | awk '{print "tkn resource delete "$1 " -f"}'| sh