.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-tcx clean-build clean-pyc clean-test ## remove all tcex, build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

clean-tcx: ## remove tcx artifacts
	rm -fr ./pdf_reader/pdf_reader-package.log
	rm -fr ./pdf_reader/pdf_reader-libs.log
	rm -rf ./pdf_reader/lib_*
	rm -rf ./pdf_reader/setup.cfg

lint: ## check style with flake8
	flake8 pdf_reader tests

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/pdf_reader.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ pdf_reader
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: clean ## package and upload a release
	python setup.py sdist upload
	python setup.py bdist_wheel upload

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l DIST

install: clean ## install the package to the active Python's site-packages
	cd ./pdf_reader && python setup.py install

lib: clean ## download required packages into a lib directory
	cd ./pdf_reader && tclib

package: clean ## package the app for deployment to TC
	cd ./pdf_reader && tcpackage --outdir ../

collection: clean ## package the app for deployment to TC as part of a collection of apps
	cd ./pdf_reader && python app.py --package --collection --zip_out ..

validate: clean ## validate the app's install.json
	python ./pdf_reader/app.py --validate --install_json ./pdf_reader/install.json

run: clean ## run the app locally
	cd ./pdf_reader && tcrun
