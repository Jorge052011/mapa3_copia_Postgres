# 🚀 Inicio Rápido - Mapa3 con PostgreSQL

## 📦 Instalación en 3 pasos

### 1️⃣ Preparar el entorno

```bash
# Clonar repositorio
git clone <tu-repo>
cd mapa3_postgres

# Copiar variables de entorno
cp .env.example .env
```

### 2️⃣ Levantar los servicios

```bash
# Opción A: Usando make (recomendado)
make install

# Opción B: Usando docker-compose directamente
docker-compose build
docker-compose up -d
```

### 3️⃣ Acceder a la aplicación

```
✅ Aplicación:  http://localhost:8000
✅ Admin:       http://localhost:8000/admin
✅ pgAdmin:     http://localhost:5050
```

---

## 🔑 Credenciales por Defecto

### Django Admin
- **Usuario**: admin
- **Contraseña**: admin123
- **URL**: http://localhost:8000/admin

### pgAdmin
- **Email**: admin@mapa3.com
- **Contraseña**: admin123
- **URL**: http://localhost:5050

### PostgreSQL (para conexiones externas)
- **Host**: localhost
- **Puerto**: 5432
- **Base de datos**: mapa3_db
- **Usuario**: mapa3_user
- **Contraseña**: mapa3_password_2024

---

## 🛠️ Comandos Esenciales

### Usando Make (más fácil)

```bash
make help          # Ver todos los comandos
make up            # Iniciar servicios
make down          # Detener servicios
make logs          # Ver logs
make shell         # Shell de Django
make migrate       # Aplicar migraciones
make backup        # Crear backup
```

### Usando Docker Compose

```bash
# Iniciar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Shell Django
docker-compose exec web python manage.py shell

# Migraciones
docker-compose exec web python manage.py migrate
```

---

## 🐘 Conectar a PostgreSQL desde pgAdmin

### Método 1: Configuración Automática
El servidor ya está preconfigurado. Solo abre http://localhost:5050

### Método 2: Configuración Manual
1. Abrir pgAdmin → http://localhost:5050
2. Login: admin@mapa3.com / admin123
3. Click derecho en "Servers" → "Register" → "Server"
4. Configurar:
   - **General → Name**: Mapa3 DB
   - **Connection → Host**: db
   - **Connection → Port**: 5432
   - **Connection → Database**: mapa3_db
   - **Connection → Username**: mapa3_user
   - **Connection → Password**: mapa3_password_2024
5. Guardar

---

## 🔄 Migrar Datos desde SQLite

### Si tienes datos en SQLite:

**1. Exportar desde SQLite:**
```bash
# En tu proyecto viejo
python manage.py dumpdata --natural-foreign --natural-primary \
  -e contenttypes -e auth.Permission \
  --indent 2 -o data.json
```

**2. Importar a PostgreSQL:**
```bash
# Copiar archivo al proyecto nuevo
cp /ruta/data.json mapa3_postgres/

# Importar
docker-compose exec web python manage.py loaddata data.json
```

---

## 🐛 Solución de Problemas Rápida

### Puerto ocupado (5432, 5050 o 8000)
```bash
# Ver qué usa el puerto
sudo lsof -i :5432

# Detener PostgreSQL local
sudo systemctl stop postgresql

# O cambiar puerto en docker-compose.yml
```

### Base de datos no responde
```bash
# Ver logs
docker-compose logs db

# Reiniciar
docker-compose restart db
```

### Empezar de cero (BORRA DATOS)
```bash
make clean
make up
```

---

## 📊 Verificar que Todo Funciona

```bash
# Ver estado de servicios
docker-compose ps

# Debería mostrar:
# mapa3_postgres_db    Up
# mapa3_pgadmin        Up
# mapa3_django         Up

# Probar conexión a Django
curl http://localhost:8000

# Probar conexión a pgAdmin
curl http://localhost:5050
```

---

## 🎯 Próximos Pasos

1. ✅ Cambiar contraseñas en `.env`
2. ✅ Configurar Google Maps API si la usas
3. ✅ Migrar datos desde SQLite (si aplica)
4. ✅ Crear usuarios adicionales
5. ✅ Configurar backups automáticos

---

## 📚 Documentación Completa

Para más detalles, ver `README.md` principal.

---

## ❓ Ayuda Rápida

### ¿Cómo ver los logs?
```bash
make logs
# o
docker-compose logs -f
```

### ¿Cómo crear un backup?
```bash
make backup
# o
docker-compose exec -T db pg_dump -U mapa3_user mapa3_db > backup.sql
```

### ¿Cómo acceder a la base de datos?
```bash
make dbshell
# o
docker-compose exec db psql -U mapa3_user -d mapa3_db
```

### ¿Cómo detener todo?
```bash
make down
# o
docker-compose down
```

---

## ✅ Checklist de Instalación

- [ ] Docker y Docker Compose instalados
- [ ] Repositorio clonado
- [ ] `.env` configurado
- [ ] Servicios levantados (`make up`)
- [ ] Django accesible en http://localhost:8000
- [ ] pgAdmin accesible en http://localhost:5050
- [ ] Puedo hacer login en Django Admin
- [ ] Puedo conectarme a PostgreSQL desde pgAdmin

---

**¡Todo listo! 🎉**

Si algo no funciona, revisa:
1. Los logs: `make logs`
2. El estado: `docker-compose ps`
3. El README.md completo
