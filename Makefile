all: pull build up push

pull:
	docker-compose pull

push:
	docker-compose push

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

downgrade:
	docker-compose run --rm --no-deps --volume=${PWD}/src:/src app bash -c '/wait && alembic downgrade -1'

dev:
	docker-compose run --volume=${PWD}/src:/src --publish=8000:8000 app bash -c 'uvicorn app.internal.main:app --host 0.0.0.0 --port 8000 --reload'

dev_test:
	docker-compose run --volume=${PWD}/src:/src/ app pytest $(if $m, -m $m)  $(if $k, -k $k) $o

poetry_lock:
	docker-compose run --rm --no-deps --volume=${PWD}:${PWD} --workdir=${PWD} app poetry lock --no-update
	sudo chown -R ${USER} ./poetry.lock

poetry_add:
	docker-compose run --rm --no-deps --volume=${PWD}:${PWD} --workdir=${PWD} app poetry add $p
	sudo chown -R ${USER} ./poetry.lock ./pyproject.toml

test:
	docker-compose run app pytest

precommit-install:
	pip install pre-commit
	pre-commit install

lint:
	pre-commit run --all-files

isort:
	docker-compose run --rm --no-deps app isort --check --diff .

flake8:
	docker-compose run --rm --no-deps app flake8 --config setup.cfg

black:
	docker-compose run --rm --no-deps app black --check --config pyproject.toml .

docker_lint:
	make isort
	make black
	make flake8

.PHONY: all build up down dev celery celerybeat dev_test update_or_create_user_groups update_roles vacation test debug dotenv precommit-install

