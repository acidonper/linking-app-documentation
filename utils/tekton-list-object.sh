#!/bin/sh
##
# Script to clean principal objects in tekton through tkn client
##


echo "EvenListeners: "
tkn eventlistener list 
echo "***"
echo ""
echo "TriggerBindings: "
tkn triggerbinding list 
echo "***"
echo ""
echo "TriggerTemaples: "
tkn triggertemplate list 
echo "***"
echo ""
echo "Pipelines: "
tkn pipeline list 
echo "***"
echo ""
echo "Tasks: "
tkn task list
echo "***"
echo ""
echo "Resources: "
tkn resource list 