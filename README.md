# 🚀 Mapa3 - Sistema de Distribución con PostgreSQL y pgAdmin

Sistema de gestión de distribución, CRM y balance contable desarrollado en Django con PostgreSQL y pgAdmin.

## 📋 Índice

- [Requisitos](#requisitos)
- [Instalación Rápida](#instalación-rápida)
- [Configuración](#configuración)
- [Uso](#uso)
- [Acceso a Servicios](#acceso-a-servicios)
- [Comandos Útiles](#comandos-útiles)
- [Migración de Datos](#migración-de-datos)
- [Troubleshooting](#troubleshooting)

---

## 📦 Requisitos

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git**

> **Nota**: No necesitas instalar Python, PostgreSQL ni pgAdmin localmente. Docker se encarga de todo.

---

## ⚡ Instalación Rápida

### 1. Clonar el repositorio

```bash
git clone <tu-repositorio>
cd mapa3_postgres
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita el archivo `.env` si quieres cambiar las credenciales:

```bash
nano .env  # o usa tu editor favorito
```

### 3. Levantar los servicios

```bash
docker-compose up -d
```

Esto iniciará 3 contenedores:
- 🐘 **PostgreSQL** - Base de datos en el puerto 5432
- 🔧 **pgAdmin** - Administrador web en el puerto 5050
- 🌐 **Django** - Aplicación web en el puerto 8000

### 4. Verificar que todo está funcionando

```bash
docker-compose ps
```

Deberías ver algo como:

```
NAME                  STATUS      PORTS
mapa3_postgres_db     Up          0.0.0.0:5432->5432/tcp
mapa3_pgadmin         Up          0.0.0.0:5050->80/tcp
mapa3_django          Up          0.0.0.0:8000->8000/tcp
```

---

## 🔧 Configuración

### Variables de Entorno (.env)

```bash
# Django
SECRET_KEY=tu-secret-key-aqui
DEBUG=True

# PostgreSQL
POSTGRES_DB=mapa3_db
POSTGRES_USER=mapa3_user
POSTGRES_PASSWORD=mapa3_password_2024
POSTGRES_HOST=db
POSTGRES_PORT=5432

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@mapa3.com
PGADMIN_DEFAULT_PASSWORD=admin123

# Google Maps (opcional)
GOOGLE_MAPS_API_KEY=tu_api_key_aqui
```

---

## 🚀 Uso

### Acceso a los Servicios

| Servicio | URL | Usuario | Contraseña |
|----------|-----|---------|------------|
| **Django Admin** | http://localhost:8000/admin/ | `admin` | `admin123` |
| **pgAdmin** | http://localhost:5050 | `admin@mapa3.com` | `admin123` |
| **Aplicación** | http://localhost:8000 | - | - |

### Primera vez: Crear Superusuario

El superusuario se crea automáticamente con:
- **Usuario**: admin
- **Contraseña**: admin123

Si quieres crear otro:

```bash
docker-compose exec web python manage.py createsuperuser
```

---

## 🐘 Acceso a pgAdmin

### 1. Abrir pgAdmin

Navega a: http://localhost:5050

### 2. Iniciar sesión

- **Email**: admin@mapa3.com
- **Password**: admin123

### 3. Conectar al servidor PostgreSQL

El servidor ya está preconfigurado. Si necesitas agregarlo manualmente:

**Opción A: Usando la interfaz**

1. Click derecho en "Servers" → "Register" → "Server"
2. En la pestaña **General**:
   - Name: `Mapa3 PostgreSQL`
3. En la pestaña **Connection**:
   - Host: `db`
   - Port: `5432`
   - Database: `mapa3_db`
   - Username: `mapa3_user`
   - Password: `mapa3_password_2024`
4. Click en "Save"

**Opción B: Desde tu máquina local**

Si quieres conectar con una herramienta externa (DBeaver, DataGrip, etc.):

- Host: `localhost` (o `127.0.0.1`)
- Port: `5432`
- Database: `mapa3_db`
- Username: `mapa3_user`
- Password: `mapa3_password_2024`

---

## 📊 Comandos Útiles

### Gestión de Contenedores

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs solo de Django
docker-compose logs -f web

# Ver logs solo de PostgreSQL
docker-compose logs -f db

# Detener servicios
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar TODO (incluye volúmenes/datos)
docker-compose down -v
```

### Django Commands

```bash
# Acceder a shell de Django
docker-compose exec web python manage.py shell

# Crear migraciones
docker-compose exec web python manage.py makemigrations

# Aplicar migraciones
docker-compose exec web python manage.py migrate

# Crear superusuario
docker-compose exec web python manage.py createsuperuser

# Colectar archivos estáticos
docker-compose exec web python manage.py collectstatic

# Ver estructura de base de datos
docker-compose exec web python manage.py dbshell
```

### PostgreSQL Commands

```bash
# Acceder a PostgreSQL directamente
docker-compose exec db psql -U mapa3_user -d mapa3_db

# Ver todas las tablas
docker-compose exec db psql -U mapa3_user -d mapa3_db -c "\dt"

# Backup de la base de datos
docker-compose exec db pg_dump -U mapa3_user mapa3_db > backup.sql

# Restaurar base de datos
docker-compose exec -T db psql -U mapa3_user -d mapa3_db < backup.sql
```

---

## 🔄 Migración de Datos desde SQLite

Si tienes datos en SQLite y quieres migrarlos a PostgreSQL:

### Método 1: Usando dumpdata/loaddata (recomendado)

**En tu proyecto SQLite original:**

```bash
# Exportar datos
python manage.py dumpdata --natural-foreign --natural-primary \
  -e contenttypes -e auth.Permission \
  --indent 2 -o data.json
```

**En el proyecto PostgreSQL:**

```bash
# Copiar el archivo al contenedor
docker cp data.json mapa3_django:/app/

# Importar datos
docker-compose exec web python manage.py loaddata data.json
```

### Método 2: Script de migración automático

```bash
# Crear script
docker-compose exec web python manage.py shell

# Dentro del shell:
from django.core.management import call_command
from crm.models import Cliente, Venta, Producto
from rutas.models import PuntoEntrega, Ruta

# Vaciar tablas (cuidado!)
Cliente.objects.all().delete()
Producto.objects.all().delete()
# ... continuar con tus modelos

# Cargar fixtures si los tienes
call_command('loaddata', 'initial_data.json')
```

---

## 🐛 Troubleshooting

### Puerto 5432 ya está en uso

Si tienes PostgreSQL instalado localmente:

```bash
# Detener PostgreSQL local (Ubuntu/Debian)
sudo systemctl stop postgresql

# O cambiar el puerto en docker-compose.yml
ports:
  - "5433:5432"  # Usar puerto 5433 externamente
```

### Puerto 8000 ya está en uso

```bash
# Cambiar en docker-compose.yml
ports:
  - "8001:8000"  # Usar puerto 8001 externamente
```

### No puedo conectarme a pgAdmin

```bash
# Ver logs de pgAdmin
docker-compose logs pgadmin

# Reiniciar pgAdmin
docker-compose restart pgadmin
```

### Error de permisos en logs/

```bash
# Crear directorio con permisos
mkdir -p logs
chmod 777 logs
```

### Base de datos corrupta / Empezar de cero

```bash
# CUIDADO: Esto borrará todos los datos
docker-compose down -v
docker-compose up -d
```

### Ver información de conexión de Django

```bash
docker-compose exec web python manage.py shell

>>> from django.conf import settings
>>> print(settings.DATABASES)
```

---

## 📁 Estructura del Proyecto

```
mapa3_postgres/
├── docker-compose.yml          # Orquestación de servicios
├── Dockerfile                  # Imagen de Django
├── entrypoint.sh              # Script de inicio
├── requirements.txt           # Dependencias Python
├── .env                       # Variables de entorno (no commitear)
├── .env.example              # Plantilla de variables
├── .dockerignore             # Archivos ignorados por Docker
├── .gitignore                # Archivos ignorados por Git
├── pgadmin_servers.json      # Configuración de pgAdmin
├── DistribucionApp/          # Configuración Django
│   ├── settings.py           # Settings con PostgreSQL
│   ├── urls.py
│   └── wsgi.py
├── crm/                      # App de CRM
│   ├── models.py
│   ├── views.py
│   └── ...
└── rutas/                    # App de rutas
    ├── models.py
    ├── views.py
    └── ...
```

---

## 🔒 Seguridad en Producción

Antes de pasar a producción:

1. **Cambiar SECRET_KEY** en `.env`
2. **Cambiar contraseñas** de PostgreSQL y pgAdmin
3. **Configurar DEBUG=False**
4. **Configurar ALLOWED_HOSTS** correctamente
5. **Usar HTTPS**
6. **Configurar firewall** para PostgreSQL
7. **Backups automáticos** de la base de datos

---

## 📝 Notas Adicionales

### Respaldos Automáticos

Puedes crear un cron job para backups automáticos:

```bash
# Crear script de backup
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T db pg_dump -U mapa3_user mapa3_db > "backups/backup_$DATE.sql"
# Mantener solo últimos 7 días
find backups/ -name "backup_*.sql" -mtime +7 -delete
EOF

chmod +x backup.sh

# Agregar a crontab (diario a las 2am)
crontab -e
# Agregar: 0 2 * * * /ruta/al/proyecto/backup.sh
```

### Actualizar la Aplicación

```bash
# Detener servicios
docker-compose down

# Actualizar código (git pull, etc.)
git pull

# Reconstruir imágenes
docker-compose build

# Iniciar servicios
docker-compose up -d

# Aplicar migraciones
docker-compose exec web python manage.py migrate
```

---

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crea un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

## 📧 Contacto

Para preguntas o soporte, contacta a: admin@mapa3.com

---

## 🎉 ¡Listo para usar!

Tu sistema está configurado y listo. Accede a:

- 🌐 **Aplicación**: http://localhost:8000
- 🔐 **Admin Django**: http://localhost:8000/admin/
- 🐘 **pgAdmin**: http://localhost:5050

**Credenciales por defecto**:
- Django Admin: `admin` / `admin123`
- pgAdmin: `admin@mapa3.com` / `admin123`

---

**¡Feliz desarrollo! 🚀**



0) Reglas de oro antes de empezar

No mezcles bases: cuando exportes, tu DATABASES debe apuntar a SQLite. Cuando importes, debe apuntar a Postgres.

Idealmente, que el código y migraciones estén iguales (o al menos compatibles) en ambos proyectos.

1) En la app antigua (SQLite): exporta datos

En el proyecto antiguo (donde está db.sqlite3):

python manage.py dumpdata \
  --natural-foreign --natural-primary \
  --exclude contenttypes --exclude auth.permission \
  --indent 2 > data.json


Opcional (recomendado): guarda también usuarios/permisos de forma segura (lo anterior ya incluye users, groups, etc., solo excluye tablas que se regeneran bien).

2) En la app nueva (Postgres): crea tablas vacías

En tu app nueva (la que está con Postgres):

python manage.py migrate


Si usas Docker/Codespaces y tu contenedor de Django se llama mapa3_django, puedes hacerlo así:

docker exec -it mapa3_django python manage.py migrate

3) Copia data.json al proyecto nuevo

Si estás en el mismo repo/codespace, solo asegúrate que data.json esté en la raíz del proyecto nuevo.

Si está en otra carpeta, muévelo.

4) Importa los datos a Postgres
python manage.py loaddata data.json


O con docker:

docker exec -it mapa3_django python manage.py loaddata data.json

5) Repara secuencias (IDs autoincrement) en Postgres

Esto evita errores al crear nuevos registros (muy común después de importar):

python manage.py sqlsequencereset app1 app2 | python manage.py dbshell


Ejemplo: si tus apps son core shop rutas:

python manage.py sqlsequencereset core shop rutas | python manage.py dbshell


Con docker:

docker exec -i mapa3_django python manage.py sqlsequencereset core shop rutas \
  | docker exec -i mapa3_django python manage.py dbshell

6) Verificación rápida

En pgAdmin, revisa tablas y cuenta registros.

En Django admin, prueba listar.

Si te falta el superusuario (a veces no se importa como esperas), créalo:

python manage.py createsuperuser

Cosas que suelen fallar (y cómo se arreglan)

Cambiaste modelos entre la versión SQLite y Postgres → puede fallar loaddata. Ahí conviene exportar solo ciertas apps (dumpdata appname) o ajustar el orden.

Media/archivos (imágenes, docs) no viajan en dumpdata. Esos hay que copiarlos manualmente (carpeta media/).

Si me dices los nombres de tus apps (lo que aparece en INSTALLED_APPS: por ejemplo core, shop, rutas, etc.), te dejo el comando de sqlsequencereset exacto para tu caso y te digo si conviene exportar todo o por apps.