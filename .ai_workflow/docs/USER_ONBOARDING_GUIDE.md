# User Onboarding Guide - Dashboard Automático

## 🚀 ¿Cómo obtener tu dashboard personalizado?

### **Para Usuarios Nuevos**

Cuando comiences a usar el AI Framework en tu proyecto, automáticamente obtendrás un dashboard personalizado con las métricas de **TU** proyecto específico.

#### **Paso 1: Configuración Automática**

1. **Copia el framework** a tu proyecto:
   ```bash
   # Copia el framework a tu proyecto
   cp -r /ruta/al/framework/.ai_workflow ./
   ```

2. **El dashboard se genera automáticamente** cuando:
   - Haces tu primer commit
   - Tienes archivos de proyecto (package.json, requirements.txt, etc.)
   - Haces push a GitHub (si usas GitHub Actions)

#### **Paso 2: Tu Dashboard Personalizado**

Una vez configurado, tendrás acceso a:

**Dashboard Personalizado** en `.ai_workflow/user_dashboard/index.html`:
- 📊 **Métricas de TU proyecto** (no del framework)
- 📈 **Estadísticas de TU desarrollo**
- 🎯 **Progreso de TUS tareas**
- 📱 **Responsive design** para móvil y desktop

## 🎯 Ejemplo de Dashboard de Usuario

### **Proyecto Node.js**
```
📊 Mi Proyecto Dashboard
========================

📁 Proyecto: my-awesome-app
🔧 Tipo: Node.js (JavaScript)
📄 Archivos: 156 archivos totales
💻 Código: 89 archivos de código
📊 Líneas: 5,420 líneas de código
🧪 Tests: 23 archivos de test
📚 Docs: 12 archivos de documentación

📈 Desarrollo
=============
📊 Commits: 42 commits
👥 Colaboradores: 2 personas
📅 Última actividad: 2024-07-18
🎯 Estado: Desarrollo activo

🏗️ Estado del Proyecto
=====================
✅ Build: Corriendo
🧪 Tests: Pendiente
🚀 Deploy: Listo
📊 Salud: 75% (bueno)
```

### **Proyecto Python**
```
📊 Mi Proyecto Dashboard
========================

📁 Proyecto: data-analysis-tool
🔧 Tipo: Python
📄 Archivos: 234 archivos totales
💻 Código: 67 archivos de código
📊 Líneas: 8,950 líneas de código
🧪 Tests: 45 archivos de test
📚 Docs: 15 archivos de documentación

📈 Desarrollo
=============
📊 Commits: 128 commits
👥 Colaboradores: 3 personas
📅 Última actividad: 2024-07-18
🎯 Estado: Desarrollo activo

🏗️ Estado del Proyecto
=====================
✅ Build: Corriendo
✅ Tests: Pasando
🚀 Deploy: Listo
📊 Salud: 90% (excelente)
```

## 🔄 Actualización Automática

Tu dashboard se actualiza automáticamente:

- **📅 Diariamente** a las 12 PM UTC
- **🔄 Con cada push** a la rama main
- **⚡ En tiempo real** cuando modificas archivos de proyecto
- **📊 Instantáneamente** cuando abres el dashboard

## 🎨 Personalización

### **Temas Disponibles**
- **Por defecto**: Azul/Púrpura gradient
- **Oscuro**: Tema oscuro para desarrolladores
- **Claro**: Tema claro minimalista
- **Personalizado**: Define tus propios colores

### **Métricas Personalizadas**
Añade tus propias métricas editando `user_metrics/project_dashboard_data.json`:

```json
{
  "custom_metrics": {
    "api_endpoints": 25,
    "database_tables": 12,
    "external_integrations": 5,
    "bug_fixes_this_week": 8,
    "features_completed": 15
  }
}
```

## 📱 Acceso Móvil

El dashboard está optimizado para móviles:
- **Responsive design** que se adapta a cualquier pantalla
- **Touch-friendly** controles táctiles
- **Offline viewing** funciona sin conexión
- **Fast loading** carga rápida

## 🤖 GitHub Actions (Opcional)

Si tu proyecto usa GitHub, puedes activar actualizaciones automáticas:

1. **Copia la acción** a tu proyecto:
   ```bash
   cp .ai_workflow/.github/workflows/user-project-dashboard.yml .github/workflows/
   ```

2. **Haz push** y la acción se activa automáticamente

3. **Disfruta** de actualizaciones automáticas cada vez que hagas cambios

## 🔧 Comandos Útiles

```bash
# Ver tu dashboard
open .ai_workflow/user_dashboard/index.html

# Regenerar dashboard manualmente
.ai_workflow/scripts/generate_dashboard_data.sh

# Actualizar métricas
.ai_workflow/scripts/update_user_metrics.sh

# Ver estado del sistema
./ai-dev status --user-project
```

## 🎯 Diferencias Framework vs Usuario

| Aspecto | Framework Dashboard | Usuario Dashboard |
|---------|-------------------|------------------|
| **Datos** | Framework development | TU proyecto |
| **Métricas** | Workflows, Actions, Framework | Archivos, Commits, TU código |
| **Tareas** | Framework features | TUS tareas |
| **Progreso** | Framework completion | TU progreso |
| **Salud** | Framework health | TU proyecto health |

## 🌟 Beneficios

### **Para Ti**
- 📊 **Visibilidad completa** de tu proyecto
- 🎯 **Métricas relevantes** para tu desarrollo
- 📈 **Tracking automático** de progreso
- 🔄 **Actualizaciones en tiempo real**

### **Para Tu Equipo**
- 📋 **Dashboard compartido** para el equipo
- 📊 **Métricas unificadas** para todos
- 🎯 **Seguimiento de objetivos** del proyecto
- 📈 **Reportes automáticos** de progreso

## 🚀 Próximos Pasos

1. **Configura** tu proyecto con el framework
2. **Espera** a que se genere automáticamente tu dashboard
3. **Personaliza** las métricas según tus necesidades
4. **Comparte** con tu equipo
5. **Disfruta** de las actualizaciones automáticas

---

**¡Tu dashboard personalizado te está esperando!** 🎉

*Guía generada automáticamente por el AI Framework*