setup:
	./docker/scripts/setup.sh

dev:
	docker-compose -f docker/compose/docker-compose.dev.yml up

prod:
	docker-compose -f docker/compose/docker-compose.prod.yml up -d

backup:
	./docker/scripts/backup.sh
