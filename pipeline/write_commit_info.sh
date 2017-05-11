#!/bin/bash -ex
echo \"`git log -1 --pretty=format:'%ae'`\" > commit_author_email.properties
echo \"`git log -1 --pretty=format:'%h'`\" > commit_id.properties
echo \"`git log -1 --pretty=format:'%s'`\" > commit_message.properties
