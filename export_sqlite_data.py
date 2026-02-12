#!/usr/bin/env python
"""
Script para exportar datos desde SQLite y prepararlos para PostgreSQL.
Uso: python export_sqlite_data.py
"""

import json
import sqlite3
from datetime import datetime
from pathlib import Path

def export_sqlite_to_json():
    """Exporta datos de SQLite a JSON compatible con PostgreSQL."""
    
    # Ruta a la base de datos SQLite
    db_path = Path(__file__).parent / "db.sqlite3"
    
    if not db_path.exists():
        print(f"❌ No se encontró db.sqlite3 en {db_path}")
        print("   Copia tu archivo db.sqlite3 al directorio del proyecto.")
        return
    
    print(f"📂 Exportando datos desde: {db_path}")
    
    # Conectar a SQLite
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # Para acceder por nombre de columna
    cursor = conn.cursor()
    
    # Diccionario para almacenar los datos
    export_data = {}
    
    # Obtener todas las tablas (excepto las de Django)
    cursor.execute("""
        SELECT name FROM sqlite_master 
        WHERE type='table' 
        AND name NOT LIKE 'sqlite_%'
        AND name NOT LIKE 'django_%'
        AND name NOT LIKE 'auth_%'
        ORDER BY name
    """)
    
    tables = [row[0] for row in cursor.fetchall()]
    
    print(f"\n📊 Tablas encontradas: {len(tables)}")
    
    for table in tables:
        print(f"   Exportando: {table}...", end=" ")
        
        cursor.execute(f"SELECT * FROM {table}")
        rows = cursor.fetchall()
        
        # Convertir a lista de diccionarios
        table_data = []
        for row in rows:
            row_dict = dict(zip([d[0] for d in cursor.description], row))
            table_data.append(row_dict)
        
        export_data[table] = table_data
        print(f"✅ {len(rows)} registros")
    
    # Guardar a JSON
    output_file = Path(__file__).parent / f"sqlite_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(export_data, f, indent=2, ensure_ascii=False, default=str)
    
    conn.close()
    
    print(f"\n✅ Datos exportados a: {output_file}")
    print(f"📦 Total de tablas: {len(export_data)}")
    print(f"📊 Total de registros: {sum(len(data) for data in export_data.values())}")
    
    print("\n📝 Próximos pasos:")
    print("   1. Copia este archivo JSON al proyecto PostgreSQL")
    print("   2. Usa el script import_to_postgres.py para importar")
    print(f"      docker cp {output_file.name} mapa3_django:/app/")
    print(f"      docker-compose exec web python import_to_postgres.py {output_file.name}")

if __name__ == "__main__":
    print("="*60)
    print("   EXPORTADOR DE DATOS SQLite → PostgreSQL")
    print("="*60)
    export_sqlite_to_json()
    print("="*60)
