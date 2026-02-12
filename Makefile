.PHONY: help build up down restart logs shell migrate superuser test clean backup

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construir las imágenes Docker
	docker-compose build

up: ## Iniciar todos los servicios
	docker-compose up -d
	@echo "✅ Servicios iniciados:"
	@echo "   🌐 Django:  http://localhost:8000"
	@echo "   🔐 Admin:   http://localhost:8000/admin"
	@echo "   🐘 pgAdmin: http://localhost:5050"

down: ## Detener todos los servicios
	docker-compose down

restart: ## Reiniciar todos los servicios
	docker-compose restart

logs: ## Ver logs de todos los servicios
	docker-compose logs -f

logs-web: ## Ver logs solo de Django
	docker-compose logs -f web

logs-db: ## Ver logs solo de PostgreSQL
	docker-compose logs -f db

logs-pgadmin: ## Ver logs solo de pgAdmin
	docker-compose logs -f pgadmin

shell: ## Acceder a shell de Django
	docker-compose exec web python manage.py shell

bash: ## Acceder a bash del contenedor Django
	docker-compose exec web bash

dbshell: ## Acceder a shell de PostgreSQL
	docker-compose exec db psql -U mapa3_user -d mapa3_db

migrate: ## Aplicar migraciones
	docker-compose exec web python manage.py makemigrations
	docker-compose exec web python manage.py migrate

superuser: ## Crear superusuario
	docker-compose exec web python manage.py createsuperuser

test: ## Ejecutar tests
	docker-compose exec web python manage.py test

collectstatic: ## Colectar archivos estáticos
	docker-compose exec web python manage.py collectstatic --noinput

backup: ## Crear backup de la base de datos
	@mkdir -p backups
	@echo "Creando backup..."
	@docker-compose exec -T db pg_dump -U mapa3_user mapa3_db > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup creado en backups/"

restore: ## Restaurar último backup (usar: make restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Error: Especifica el archivo con FILE=nombre.sql"; \
		exit 1; \
	fi
	@echo "Restaurando $(FILE)..."
	@docker-compose exec -T db psql -U mapa3_user -d mapa3_db < backups/$(FILE)
	@echo "✅ Backup restaurado"

clean: ## Limpiar contenedores, volúmenes e imágenes (CUIDADO: borra datos)
	@echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos"
	@echo "Presiona Ctrl+C para cancelar, Enter para continuar..."
	@read dummy
	docker-compose down -v
	docker-compose rm -f
	@echo "✅ Limpieza completa"

reset: ## Reset completo y reiniciar (CUIDADO: borra datos)
	@echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos"
	@echo "Presiona Ctrl+C para cancelar, Enter para continuar..."
	@read dummy
	docker-compose down -v
	docker-compose up -d
	@echo "⏳ Esperando a que los servicios inicien..."
	@sleep 10
	@echo "✅ Reset completo. Servicios reiniciados"

status: ## Ver estado de los servicios
	docker-compose ps

rebuild: ## Reconstruir y reiniciar todo
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✅ Reconstrucción completa"

install: ## Primera instalación (setup inicial)
	@echo "🚀 Iniciando instalación..."
	@cp -n .env.example .env || true
	@echo "✅ .env creado (edítalo si es necesario)"
	docker-compose build
	docker-compose up -d
	@echo "⏳ Esperando a que los servicios inicien..."
	@sleep 15
	@echo ""
	@echo "✅ Instalación completa!"
	@echo ""
	@echo "📋 Acceso a los servicios:"
	@echo "   🌐 Django:  http://localhost:8000"
	@echo "   🔐 Admin:   http://localhost:8000/admin (admin/admin123)"
	@echo "   🐘 pgAdmin: http://localhost:5050 (admin@mapa3.com/admin123)"
	@echo ""
	@echo "💡 Usa 'make help' para ver todos los comandos disponibles"
