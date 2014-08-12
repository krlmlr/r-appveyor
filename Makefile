all: test-failure

test-failure: FORCE
	git merge-into fail-$$(git branch | grep "[*]" | cut -d " " -f 2) --no-edit

FORCE:
