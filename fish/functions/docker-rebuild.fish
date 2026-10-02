function docker-rebuild --description "docker compose down -v then up -d"
	docker compose down -v; and docker compose up -d
end
