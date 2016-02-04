all: test-failure

install:
	git clean -fdx; R --vanilla CMD INSTALL .

test-failure: FORCE
	git merge-into $$(git branch | grep "[*]" | cut -d " " -f 2)-fail --no-edit
	git merge-into $$(git branch | grep "[*]" | cut -d " " -f 2)-nocopy --no-edit

FORCE:
