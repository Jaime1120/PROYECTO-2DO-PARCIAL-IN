# Código Completo para Visualización de Datos Sintéticos (Versión Corregida)

# Importar librerías necesarias
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
import random

# Configuración inicial
sns.set_style("whitegrid")  # Reemplaza plt.style.use('seaborn')
sns.set_palette("husl")
np.random.seed(42)
random.seed(42)

# 1. Distribución de Préstamos por Tipo
def plot_prestamos_por_tipo():
    tipos_prestamo = ['Equipo', 'Sala']
    cantidades = [7000, 3000]  # 70% equipos, 30% salas
    
    plt.figure(figsize=(10, 6))
    plt.pie(cantidades, labels=tipos_prestamo, autopct='%1.1f%%', 
            startangle=90, explode=(0.05, 0), shadow=True)
    plt.title('Distribución de Préstamos por Tipo', fontsize=14, pad=20)
    plt.show()

# 2. Préstamos Mensuales (Series de Tiempo)
def plot_prestamos_mensuales():
    fechas = pd.date_range(start='2022-01-01', end='2023-12-31', freq='M')
    prestamos_mensuales = np.random.poisson(lam=400, size=len(fechas))
    
    # Añadir estacionalidad
    prestamos_mensuales = prestamos_mensuales * np.sin(np.linspace(0, 2*np.pi, len(fechas))) * 0.2 + prestamos_mensuales
    
    df_prestamos = pd.DataFrame({
        'Fecha': fechas,
        'Préstamos': prestamos_mensuales
    })
    
    plt.figure(figsize=(14, 7))
    sns.lineplot(data=df_prestamos, x='Fecha', y='Préstamos', 
                 marker='o', linewidth=2.5, markersize=8)
    
    # Añadir línea de tendencia
    z = np.polyfit(range(len(fechas)), prestamos_mensuales, 1)
    p = np.poly1d(z)
    plt.plot(fechas, p(range(len(fechas))), "--", color='red', alpha=0.5, label='Tendencia')
    
    plt.title('Préstamos Mensuales (Últimos 2 años)', fontsize=14, pad=20)
    plt.xlabel('Mes', fontsize=12)
    plt.ylabel('Número de Préstamos', fontsize=12)
    plt.xticks(rotation=45)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()

# 3. Distribución de Préstamos por Carrera
def plot_prestamos_por_carrera():
    carreras = ['Ing. Sistemas', 'Ing. Industrial', 'Lic. Administración', 
                'Arquitectura', 'Medicina', 'Derecho', 'Psicología']
    prestamos_carrera = [1200, 850, 780, 450, 320, 280, 210]
    
    plt.figure(figsize=(12, 7))
    bars = plt.bar(carreras, prestamos_carrera, 
                   color=sns.color_palette("viridis", len(carreras)))
    
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height,
                 f'{int(height)}', ha='center', va='bottom', fontsize=10)
    
    plt.title('Préstamos por Carrera', fontsize=14, pad=20)
    plt.xlabel('Carrera', fontsize=12)
    plt.ylabel('Número de Préstamos', fontsize=12)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

# 4. Estado de los Equipos
def plot_estado_equipos():
    estados = ['Disponible', 'Prestado', 'Mantenimiento', 'Baja']
    cantidades = [320, 120, 45, 15]
    colores = ['#4CAF50', '#2196F3', '#FFC107', '#F44336']
    
    plt.figure(figsize=(10, 8))
    plt.pie(cantidades, labels=estados, autopct='%1.1f%%', 
            startangle=90, colors=colores, explode=(0.05, 0, 0, 0),
            shadow=True, textprops={'fontsize': 12})
    
    centre_circle = plt.Circle((0,0), 0.70, fc='white')
    fig = plt.gcf()
    fig.gca().add_artist(centre_circle)
    plt.title('Estado Actual de los Equipos', fontsize=14, pad=20)
    plt.show()

# 5. Reportes por Tipo de Problema
def plot_reportes_por_problema():
    problemas = ['Hardware', 'Software', 'Red', 'Mobiliario', 'Electricidad', 'Otros']
    reportes = [650, 520, 480, 250, 100, 50]
    
    plt.figure(figsize=(12, 7))
    sns.barplot(x=reportes, y=problemas, palette="magma")
    
    for i, v in enumerate(reportes):
        plt.text(v + 10, i, str(v), color='black', va='center', fontsize=10)
    
    plt.title('Reportes por Tipo de Problema', fontsize=14, pad=20)
    plt.xlabel('Número de Reportes', fontsize=12)
    plt.ylabel('Tipo de Problema', fontsize=12)
    plt.tight_layout()
    plt.show()

# 6. Uso de Salas por Edificio
def plot_uso_salas_edificio():
    edificios = ['A', 'B', 'C', 'D', 'E']
    uso_salas = [420, 380, 350, 290, 210]
    
    plt.figure(figsize=(12, 7))
    plt.fill_between(edificios, uso_salas, color="skyblue", alpha=0.4)
    plt.plot(edificios, uso_salas, marker='o', color="Slateblue", 
             alpha=0.8, linewidth=3, markersize=10)
    
    for i, v in enumerate(uso_salas):
        plt.text(i, v + 10, str(v), ha='center', fontsize=10)
    
    plt.title('Uso de Salas por Edificio', fontsize=14, pad=20)
    plt.xlabel('Edificio', fontsize=12)
    plt.ylabel('Horas de Uso', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.show()

# 7. Tiempo de Resolución de Reportes
def plot_tiempo_resolucion():
    tiempos = np.random.gamma(shape=2, scale=12, size=1000)
    tiempos = np.clip(tiempos, 0, 72)  # Limitar a 72 horas
    
    plt.figure(figsize=(14, 7))
    sns.histplot(tiempos, bins=30, kde=True, color='purple', alpha=0.6)
    
    media = np.mean(tiempos)
    mediana = np.median(tiempos)
    
    plt.axvline(x=media, color='red', linestyle='--', 
                label=f'Media: {media:.1f} hrs')
    plt.axvline(x=mediana, color='green', linestyle='--', 
                label=f'Mediana: {mediana:.1f} hrs')
    
    plt.title('Distribución del Tiempo de Resolución de Reportes', fontsize=14, pad=20)
    plt.xlabel('Horas para Resolver', fontsize=12)
    plt.ylabel('Número de Reportes', fontsize=12)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.show()

# 8. Heatmap de Uso por Hora y Día
def plot_heatmap_uso():
    dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
    horas = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
    data = np.random.poisson(lam=15, size=(len(dias), len(horas)))
    
    # Ajustar patrones
    data[-1] = data[-1] // 2  # Menos actividad los sábados
    data[:, :3] = data[:, :3] // 2  # Menos actividad temprano
    data[:, -3:] = data[:, -3:] // 2  # Menos actividad tarde
    data[2, 5:8] = data[2, 5:8] * 1.5  # Mayor actividad miércoles al mediodía
    
    plt.figure(figsize=(14, 8))
    sns.heatmap(data, xticklabels=horas, yticklabels=dias, 
                cmap="YlOrRd", annot=True, fmt="d", 
                cbar_kws={'label': 'Número de Préstamos'})
    
    plt.title('Uso de Recursos por Hora y Día', fontsize=14, pad=20)
    plt.xlabel('Hora del Día', fontsize=12)
    plt.ylabel('Día de la Semana', fontsize=12)
    plt.tight_layout()
    plt.show()

# 9. Tendencia de Inventario (Equipos Disponibles)
def plot_tendencia_inventario():
    meses = pd.date_range(start='2023-01-01', periods=12, freq='M')
    disponibles = np.random.normal(loc=300, scale=20, size=len(meses))
    disponibles = np.clip(disponibles, 250, 350)
    
    # Añadir tendencia descendente
    disponibles = disponibles * np.linspace(1, 0.85, len(meses))
    
    plt.figure(figsize=(14, 7))
    plt.fill_between(meses, disponibles, color="lightgreen", alpha=0.3)
    plt.plot(meses, disponibles, marker='o', color="green", 
             alpha=0.8, linewidth=3, markersize=8)
    
    for i, v in enumerate(disponibles):
        plt.text(meses[i], v + 5, f"{int(v)}", ha='center', fontsize=9)
    
    plt.title('Tendencia de Equipos Disponibles (2023)', fontsize=14, pad=20)
    plt.xlabel('Mes', fontsize=12)
    plt.ylabel('Equipos Disponibles', fontsize=12)
    plt.xticks(rotation=45)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.show()

# 10. Distribución de Préstamos por Turno (CORREGIDA)
def plot_prestamos_por_turno():
    turnos = ['Matutino (7-14 hrs)', 'Vespertino (14-16 hrs)', 'Nocturno (16-20 hrs)']
    prestamos = [5500, 2500, 2000]
    colores = ['#FFD700', '#FFA500', '#8B4513']
    
    plt.figure(figsize=(10, 6))
    bars = plt.bar(turnos, prestamos, color=colores)
    
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height,
                f'{int(height)}', ha='center', va='bottom', fontsize=10)
    
    plt.title('Préstamos por Turno', fontsize=14, pad=20)
    plt.xlabel('Turno', fontsize=12)
    plt.ylabel('Número de Préstamos', fontsize=12)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

# Ejecutar todas las visualizaciones
if __name__ == "__main__":
    plot_prestamos_por_tipo()
    plot_prestamos_mensuales()
    plot_prestamos_por_carrera()
    plot_estado_equipos()
    plot_reportes_por_problema()
    plot_uso_salas_edificio()
    plot_tiempo_resolucion()
    plot_heatmap_uso()
    plot_tendencia_inventario()
    plot_prestamos_por_turno()