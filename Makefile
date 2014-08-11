all: test-failure

test-failure: FORCE
	git merge-into test-failure --no-edit

FORCE:
