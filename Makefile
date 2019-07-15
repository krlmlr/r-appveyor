all: test-failure

test-failure: FORCE
	git merge-into $$(git branch | grep "[*]" | cut -d " " -f 2)-fail --no-edit
	git push $$(git branch | grep "[*]" | cut -d " " -f 2)-fail

FORCE:
