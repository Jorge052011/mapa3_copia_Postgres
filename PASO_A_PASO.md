# 📘 Guía Completa: Migración a PostgreSQL con pgAdmin

## 🎯 Objetivo
Transformar tu aplicación Django de SQLite a PostgreSQL con pgAdmin, todo dockerizado.

---

## 📦 Contenido del Proyecto

El archivo `mapa3_postgres.tar.gz` contiene:

```
mapa3_postgres/
├── 🐳 Docker
│   ├── docker-compose.yml         # Desarrollo
│   ├── docker-compose.prod.yml    # Producción
│   ├── Dockerfile                 # Imagen Django
│   ├── entrypoint.sh             # Script de inicio
│   └── .dockerignore             # Exclusiones
│
├── 🐍 Django
│   ├── DistribucionApp/          # Configuración
│   │   └── settings.py           # ✨ Actualizado para PostgreSQL
│   ├── crm/                      # App CRM
│   ├── rutas/                    # App Rutas
│   └── manage.py
│
├── ⚙️ Configuración
│   ├── .env.example              # Variables de entorno
│   ├── requirements.txt          # ✨ Con psycopg2
│   └── pgadmin_servers.json      # Config pgAdmin
│
├── 📖 Documentación
│   ├── README.md                 # Guía completa
│   ├── QUICKSTART.md             # Inicio rápido
│   └── PASO_A_PASO.md            # Este archivo
│
└── 🛠️ Utilidades
    ├── Makefile                  # Comandos rápidos
    ├── export_sqlite_data.py     # Exportar desde SQLite
    └── .gitignore
```

---

## 🚀 Instalación Paso a Paso

### Paso 1: Descomprimir el Proyecto

```bash
# Descargar y descomprimir
tar -xzf mapa3_postgres.tar.gz
cd mapa3_postgres
```

### Paso 2: Configurar Variables de Entorno

```bash
# Copiar el template
cp .env.example .env

# Editar el archivo .env
nano .env  # o tu editor favorito
```

**Contenido de .env (personaliza las contraseñas):**

```bash
# Django
SECRET_KEY=cambiar-esto-por-algo-seguro-$(openssl rand -hex 32)
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# PostgreSQL
POSTGRES_DB=mapa3_db
POSTGRES_USER=mapa3_user
POSTGRES_PASSWORD=tu_contraseña_segura_aqui
POSTGRES_HOST=db
POSTGRES_PORT=5432

# pgAdmin
PGADMIN_DEFAULT_EMAIL=tu_email@ejemplo.com
PGADMIN_DEFAULT_PASSWORD=tu_contraseña_pgadmin
```

### Paso 3: Construir y Levantar Servicios

```bash
# Opción A: Usando Make (recomendado)
make install

# Opción B: Usando Docker Compose
docker-compose build
docker-compose up -d
```

**Espera 15-30 segundos** mientras los servicios inician.

### Paso 4: Verificar que Todo Funciona

```bash
# Ver estado de servicios
docker-compose ps

# Deberías ver algo como:
# NAME                STATUS              PORTS
# mapa3_django        Up                  0.0.0.0:8000->8000/tcp
# mapa3_pgadmin       Up                  0.0.0.0:5050->80/tcp
# mapa3_postgres_db   Up                  0.0.0.0:5432->5432/tcp
```

### Paso 5: Acceder a los Servicios

Abre tu navegador y verifica:

1. **Django**: http://localhost:8000
   - Deberías ver la aplicación funcionando

2. **Django Admin**: http://localhost:8000/admin
   - Usuario: `admin`
   - Contraseña: `admin123`

3. **pgAdmin**: http://localhost:5050
   - Email: `admin@mapa3.com` (o el que pusiste en .env)
   - Contraseña: `admin123` (o la que pusiste en .env)

---

## 🐘 Conectar pgAdmin a PostgreSQL

### Opción 1: Servidor Pre-configurado

El servidor ya debería aparecer en pgAdmin. Solo haz clic en "Servers" → "Mapa3 PostgreSQL".

Si pide contraseña: `mapa3_password_2024` (o la que configuraste)

### Opción 2: Configurar Manualmente

1. Abrir pgAdmin: http://localhost:5050
2. Login con tus credenciales
3. Click derecho en "Servers" → "Register" → "Server"
4. En la pestaña **General**:
   - Name: `Mapa3 DB`
5. En la pestaña **Connection**:
   - Host name/address: `db`
   - Port: `5432`
   - Maintenance database: `mapa3_db`
   - Username: `mapa3_user`
   - Password: `mapa3_password_2024`
6. Click "Save"

### Explorar la Base de Datos

Una vez conectado:

1. Expande: Servers → Mapa3 DB → Databases → mapa3_db
2. Expande: Schemas → public → Tables
3. Verás todas las tablas de Django:
   - `crm_cliente`
   - `crm_producto`
   - `crm_venta`
   - `rutas_puntoentrega`
   - etc.

---

## 🔄 Migrar Datos desde SQLite

### Opción 1: Usando dumpdata/loaddata (Recomendado)

**En tu proyecto SQLite ORIGINAL:**

```bash
# Ir al directorio del proyecto viejo
cd /ruta/al/proyecto/viejo

# Activar entorno virtual (si usas uno)
source venv/bin/activate

# Exportar TODOS los datos
python manage.py dumpdata \
  --natural-foreign \
  --natural-primary \
  -e contenttypes \
  -e auth.Permission \
  --indent 2 \
  -o data_completo.json

# O exportar solo apps específicas
python manage.py dumpdata crm \
  --natural-foreign \
  --natural-primary \
  --indent 2 \
  -o data_crm.json

python manage.py dumpdata rutas \
  --natural-foreign \
  --natural-primary \
  --indent 2 \
  -o data_rutas.json
```

**En el proyecto PostgreSQL NUEVO:**

```bash
# Copiar archivo(s) al contenedor
docker cp data_completo.json mapa3_django:/app/

# Importar datos
docker-compose exec web python manage.py loaddata data_completo.json

# O importar por partes
docker cp data_crm.json mapa3_django:/app/
docker cp data_rutas.json mapa3_django:/app/
docker-compose exec web python manage.py loaddata data_crm.json
docker-compose exec web python manage.py loaddata data_rutas.json
```

### Opción 2: Migración Manual de Tablas Específicas

Si solo quieres migrar algunas tablas:

**1. Exportar desde SQLite:**

```bash
cd /ruta/al/proyecto/viejo
python manage.py dumpdata crm.Cliente --indent 2 -o clientes.json
python manage.py dumpdata crm.Producto --indent 2 -o productos.json
```

**2. Importar a PostgreSQL:**

```bash
docker cp clientes.json mapa3_django:/app/
docker cp productos.json mapa3_django:/app/
docker-compose exec web python manage.py loaddata clientes.json
docker-compose exec web python manage.py loaddata productos.json
```

### Opción 3: Script de Exportación (Incluido)

```bash
# En el proyecto viejo, copiar el script
cp /ruta/al/proyecto/nuevo/export_sqlite_data.py .

# Ejecutar
python export_sqlite_data.py

# Esto creará: sqlite_export_FECHA.json
# Copiar al proyecto nuevo e importar
```

---

## 🛠️ Comandos Útiles Diarios

### Gestión de Servicios

```bash
# Iniciar
make up
# o: docker-compose up -d

# Detener
make down
# o: docker-compose down

# Reiniciar
make restart
# o: docker-compose restart

# Ver logs
make logs
# o: docker-compose logs -f
```

### Django Management

```bash
# Shell de Django
make shell
# o: docker-compose exec web python manage.py shell

# Migraciones
make migrate
# o: docker-compose exec web python manage.py makemigrations
#    docker-compose exec web python manage.py migrate

# Crear superusuario
make superuser
# o: docker-compose exec web python manage.py createsuperuser

# Colectar estáticos
make collectstatic
```

### Base de Datos

```bash
# Acceder a PostgreSQL
make dbshell
# o: docker-compose exec db psql -U mapa3_user -d mapa3_db

# Dentro de PostgreSQL:
\dt                              # Listar tablas
\d nombre_tabla                  # Ver estructura de tabla
SELECT * FROM crm_cliente;       # Consultar datos
\q                               # Salir

# Backup
make backup
# o: docker-compose exec -T db pg_dump -U mapa3_user mapa3_db > backup.sql

# Restaurar
docker-compose exec -T db psql -U mapa3_user -d mapa3_db < backup.sql
```

---

## 🎨 Personalización

### Cambiar Puertos

Edita `docker-compose.yml`:

```yaml
services:
  web:
    ports:
      - "8001:8000"  # Usar puerto 8001 en lugar de 8000

  pgadmin:
    ports:
      - "5051:80"    # Usar puerto 5051 en lugar de 5050

  db:
    ports:
      - "5433:5432"  # Usar puerto 5433 en lugar de 5432
```

### Agregar Variables de Entorno

Edita `.env` y luego en `docker-compose.yml`:

```yaml
services:
  web:
    environment:
      - MI_VARIABLE=${MI_VARIABLE}
```

### Cambiar Nombres de Contenedores

En `docker-compose.yml`:

```yaml
services:
  db:
    container_name: mi_postgres_db
```

---

## 🔒 Preparar para Producción

### 1. Cambiar Contraseñas

Edita `.env`:

```bash
SECRET_KEY=$(openssl rand -hex 32)
DEBUG=False
POSTGRES_PASSWORD=contraseña_muy_segura_aqui
PGADMIN_DEFAULT_PASSWORD=otra_contraseña_segura
```

### 2. Configurar ALLOWED_HOSTS

En `.env`:

```bash
ALLOWED_HOSTS=tudominio.com,www.tudominio.com
```

### 3. Usar Configuración de Producción

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Configurar SSL/HTTPS

Ver sección de Nginx en el README.md principal.

---

## 🐛 Solución de Problemas

### Error: "Port already in use"

**Puerto 5432 (PostgreSQL):**
```bash
# Ver qué usa el puerto
sudo lsof -i :5432

# Detener PostgreSQL local
sudo systemctl stop postgresql

# O cambiar puerto en docker-compose.yml
```

**Puerto 8000 (Django):**
```bash
# Cambiar a otro puerto en docker-compose.yml
ports:
  - "8001:8000"
```

### Error: "Database connection failed"

```bash
# Ver logs de PostgreSQL
docker-compose logs db

# Verificar que PostgreSQL esté levantado
docker-compose ps

# Reiniciar base de datos
docker-compose restart db
```

### Error: "Permission denied" en logs/

```bash
# Crear directorio con permisos
mkdir -p logs
sudo chown -R $USER:$USER logs
chmod 755 logs
```

### Contenedores no inician

```bash
# Ver logs detallados
docker-compose logs

# Reconstruir imágenes
docker-compose build --no-cache
docker-compose up -d
```

### Base de datos corrupta / Empezar de cero

```bash
# ⚠️ CUIDADO: Esto borra TODOS los datos
docker-compose down -v
docker-compose up -d
```

### No puedo acceder a pgAdmin

```bash
# Ver logs
docker-compose logs pgadmin

# Verificar puerto
curl http://localhost:5050

# Reiniciar
docker-compose restart pgadmin
```

---

## 📊 Verificación Final

### Checklist de Instalación

- [ ] Docker y Docker Compose instalados
- [ ] Proyecto descomprimido
- [ ] .env configurado con contraseñas
- [ ] `docker-compose up -d` ejecutado sin errores
- [ ] Django accesible en http://localhost:8000
- [ ] Django Admin funciona (admin/admin123)
- [ ] pgAdmin accesible en http://localhost:5050
- [ ] pgAdmin conectado a PostgreSQL
- [ ] Puedo ver las tablas en pgAdmin
- [ ] Datos migrados desde SQLite (si aplica)

### Tests de Funcionalidad

```bash
# Test 1: Django responde
curl http://localhost:8000

# Test 2: Django Admin accesible
curl http://localhost:8000/admin/

# Test 3: pgAdmin responde
curl http://localhost:5050

# Test 4: PostgreSQL acepta conexiones
docker-compose exec db psql -U mapa3_user -d mapa3_db -c "SELECT 1"

# Test 5: Ver tablas en Django
docker-compose exec web python manage.py showmigrations
```

---

## 📚 Recursos Adicionales

### Archivos de Referencia

- `README.md` - Documentación completa
- `QUICKSTART.md` - Guía rápida
- `Makefile` - Lista de comandos disponibles

### Comandos Frecuentes

```bash
# Ver ayuda de Make
make help

# Ver estructura de base de datos
docker-compose exec web python manage.py inspectdb

# Ejecutar tests
docker-compose exec web python manage.py test

# Shell interactivo
docker-compose exec web python manage.py shell
```

### Logs y Debugging

```bash
# Logs en tiempo real
docker-compose logs -f

# Logs de un servicio específico
docker-compose logs -f web     # Django
docker-compose logs -f db      # PostgreSQL
docker-compose logs -f pgadmin # pgAdmin

# Últimas 100 líneas
docker-compose logs --tail=100
```

---

## ✅ Próximos Pasos Recomendados

1. **Cambiar contraseñas por defecto**
   ```bash
   nano .env
   docker-compose restart
   ```

2. **Crear usuarios adicionales**
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

3. **Configurar backups automáticos**
   ```bash
   # Ver sección de backups en README.md
   make backup
   ```

4. **Explorar tu base de datos en pgAdmin**
   - Conectarte al servidor
   - Explorar schemas y tablas
   - Ejecutar consultas SQL

5. **Migrar tus datos si vienes de SQLite**
   - Usar dumpdata/loaddata
   - Verificar que todo esté correcto

6. **Personalizar la aplicación**
   - Editar settings.py si necesario
   - Agregar tus propias apps
   - Configurar Google Maps API

---

## 🎉 ¡Felicidades!

Tu aplicación Django ahora está corriendo con:
- ✅ PostgreSQL como base de datos
- ✅ pgAdmin para administración visual
- ✅ Todo dockerizado y fácil de desplegar
- ✅ Migraciones automáticas
- ✅ Backups simples

---

## 💡 Consejos Profesionales

1. **Haz backups regularmente**
   ```bash
   # Agregar a crontab para backup diario
   0 2 * * * cd /ruta/proyecto && make backup
   ```

2. **Monitorea los logs**
   ```bash
   # Ver errores en tiempo real
   docker-compose logs -f | grep ERROR
   ```

3. **Usa .env para secretos**
   - Nunca commitees .env a Git
   - Usa .env.example como template

4. **Mantén Docker actualizado**
   ```bash
   docker --version
   docker-compose --version
   ```

5. **Documenta tus cambios**
   - Actualiza README.md con tus personalizaciones
   - Mantén un CHANGELOG

---

**¿Necesitas ayuda?**
- Revisa los logs: `make logs`
- Consulta README.md
- Verifica el estado: `docker-compose ps`

**¡Tu sistema está listo para usar! 🚀**
