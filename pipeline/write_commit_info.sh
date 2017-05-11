#!/bin/bash -ex
echo \"`git log -1 --pretty=format:'%ae %h %s'`\" > commit_info.properties
