#!/bin/sh

test_description='fetch just one branch'

. ./test-lib.sh
. "$TEST_DIRECTORY"/lib-httpd.sh
start_httpd

test_expect_success 'setup repo' '
	git init "$HTTPD_DOCUMENT_ROOT_PATH/repo.git" &&
	(
		cd "$HTTPD_DOCUMENT_ROOT_PATH/repo.git" &&
		test_commit 1
	)
'

test_expect_success 'clone http repository' '
	git clone $HTTPD_URL/smart/repo.git clone
'

test_expect_success 'make some more commits' '
	(
		cd "$HTTPD_DOCUMENT_ROOT_PATH/repo.git" &&
		test_commit 2 &&
		git checkout -b another_branch &&
		test_commit 3
		git checkout -b a_third_branch &&
		test_commit 4
	)
'

test_expect_success 'fetch with refspec only fetches requested branch' '
	test_when_finished "rm trace" &&
	(
		cd clone &&
		GIT_TRACE_PACKET="$TRASH_DIRECTORY/trace" git fetch origin another_branch &&
		! grep "refs/heads/master" ../trace
	)
'

test_expect_success 'single-branch clone only fetches requested branch' '
	GIT_TRACE_PACKET="$TRASH_DIRECTORY/trace" git clone --single-branch -b master $HTTPD_URL/smart/repo.git sbc &&
	! grep "refs/heads/another_branch" trace
'

stop_httpd
test_done
