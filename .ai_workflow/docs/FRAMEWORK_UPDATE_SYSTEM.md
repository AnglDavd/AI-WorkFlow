# Framework Update System

## 🚨 Problema Identificado

### **Situación Actual:**
```bash
# Usuario instala framework
git clone https://github.com/user/ai-framework.git
cd ai-framework

# Usuario ejecuta setup
./ai-dev setup
# ❌ Esto modifica archivos del framework

# Usuario quiere actualizar
git pull origin main
# ❌ CONFLICTO: archivos modificados vs actualizaciones
```

### **Consecuencias:**
- **Usuarios atrapados**: No pueden actualizar sin perder customizaciones
- **Fragmentación**: Versiones diferentes en cada usuario
- **Soporte difícil**: Difícil diagnosticar problemas
- **Adopción limitada**: Miedo a actualizaciones

## 💡 Solución Implementada

### **Arquitectura Nueva:**

```bash
# Framework Core (inmutable)
ai-framework/
├── .ai_workflow/           # Framework templates y workflows
├── ai-dev                  # CLI principal
├── .github/               # GitHub Actions
└── docs/                  # Documentación

# Proyecto Usuario (mutable)
user-project/
├── .ai_workflow/          # Datos específicos del usuario
│   ├── config/           # ✅ Configuración del proyecto
│   ├── PRPs/             # ✅ PRPs del proyecto
│   ├── state/            # ✅ Estado del proyecto
│   └── *_custom.md       # ✅ Workflows customizados
├── ai-dev -> ../ai-framework/ai-dev  # Symlink al CLI
└── project files...
```

### **Comando de Actualización:**

```bash
# Desde framework repository
./ai-dev update              # Actualiza framework core

# Desde user project
./ai-dev update              # Actualiza componentes del framework
```

## 🛠️ Cómo Funciona

### **Detección Automática:**
1. **Framework Repository**: Detecta `ai-dev` + `.ai_workflow` + `.github`
2. **User Project**: Detecta solo `.ai_workflow` (sin `ai-dev`)

### **Proceso de Actualización:**

#### **Para Framework Repository:**
```bash
./ai-dev update
# 1. Verifica uncommitted changes
# 2. Fetch from remote
# 3. Muestra cambios a aplicar
# 4. Merge con remote
# 5. Verificación de integridad
```

#### **Para User Project:**
```bash
./ai-dev update
# 1. Localiza framework installation
# 2. Backup de customizaciones
# 3. Actualiza componentes core
# 4. Preserva datos de usuario
# 5. Restaura customizaciones
```

## 📋 Archivos Protegidos

### **Nunca se Sobrescriben:**
- `.ai_workflow/config/` - Configuración del usuario
- `.ai_workflow/PRPs/` - PRPs del proyecto
- `.ai_workflow/state/` - Estado del proyecto
- `*_custom.md` - Workflows customizados

### **Siempre se Actualizan:**
- `.ai_workflow/workflows/` - Workflows base
- `.ai_workflow/commands/` - Comandos del framework
- `.ai_workflow/ARCHITECTURE.md` - Documentación
- `.ai_workflow/GLOBAL_AI_RULES.md` - Reglas globales

## 🔄 Flujo de Actualización

### **Paso 1: Backup Automático**
```bash
# Se crea automáticamente
.ai_workflow_backup_20250718_143022/
├── config/
├── PRPs/
├── state/
└── *_custom.md
```

### **Paso 2: Actualización Selectiva**
```bash
# Solo se actualizan archivos del framework
rsync --exclude='config/' --exclude='PRPs/' --exclude='state/' \
    framework/.ai_workflow/ user-project/.ai_workflow/
```

### **Paso 3: Restauración**
```bash
# Se restauran archivos del usuario
cp -r backup/config .ai_workflow/
cp -r backup/PRPs .ai_workflow/
cp -r backup/state .ai_workflow/
```

## 📊 Casos de Uso

### **Caso 1: Desarrollador del Framework**
```bash
cd ai-framework
./ai-dev update
# ✅ Actualiza framework desde GitHub
```

### **Caso 2: Usuario con Proyecto**
```bash
cd mi-proyecto
./ai-dev update
# ✅ Actualiza componentes del framework
# ✅ Preserva configuración y PRPs
```

### **Caso 3: Instalación Global**
```bash
# Futuro: instalación como package
npm install -g ai-framework
ai-dev update
# ✅ Actualiza instalación global
```

## 🛡️ Características de Seguridad

### **Backup Automático:**
- Backup antes de cada actualización
- Timestamp único para evitar colisiones
- Recuperación fácil en caso de problemas

### **Validación:**
- Verificación de integridad post-actualización
- Rollback automático si falla
- Logs detallados de operaciones

### **Preservación:**
- Customizaciones del usuario intactas
- Configuraciones preservadas
- Estado del proyecto mantenido

## 🎯 Beneficios

### **Para Usuarios:**
- **Actualizaciones seguras**: Sin miedo a perder customizaciones
- **Proceso simple**: Un solo comando
- **Rollback fácil**: Backups automáticos
- **Zero-downtime**: Proyecto funcional durante actualización

### **Para Desarrolladores:**
- **Distribución fácil**: Usuarios pueden actualizar
- **Soporte mejorado**: Versiones consistentes
- **Feedback mejor**: Usuarios en versiones actuales
- **Adopción mayor**: Actualizaciones sin riesgo

## 🔮 Futuras Mejoras

### **Distribución como Package:**
```bash
# Instalación global
npm install -g @ai-framework/cli
pip install ai-framework-cli
cargo install ai-framework

# Uso en cualquier proyecto
ai-dev setup
ai-dev update
```

### **Update Channels:**
```bash
# Canales de actualización
ai-dev update --channel stable
ai-dev update --channel beta
ai-dev update --channel nightly
```

### **Selective Updates:**
```bash
# Actualización selectiva
ai-dev update --workflows-only
ai-dev update --docs-only
ai-dev update --security-only
```

## 📝 Guía de Uso

### **Para Usuarios Existentes:**
1. **Commitear cambios** antes de actualizar
2. **Ejecutar** `./ai-dev update`
3. **Verificar** con `./ai-dev diagnose`
4. **Rollback** si hay problemas (usar backup)

### **Para Nuevos Usuarios:**
1. **Clonar** framework repository
2. **Ejecutar** `./ai-dev setup` en su proyecto
3. **Actualizar** con `./ai-dev update` cuando necesario

### **Resolución de Problemas:**
```bash
# Si falla la actualización
ls -la .ai_workflow_backup_*
# Restaurar desde backup más reciente

# Si no encuentra framework
./ai-dev update --framework-path /path/to/framework
```

## ✅ Estado de Implementación

### **Implementado:**
- ✅ Comando `./ai-dev update`
- ✅ Detección automática de contexto
- ✅ Backup automático de customizaciones
- ✅ Actualización selectiva de componentes
- ✅ Restauración de datos de usuario
- ✅ Validación post-actualización

### **Por Implementar:**
- [ ] Distribución como package
- [ ] Update channels
- [ ] Selective updates
- [ ] Notificaciones automáticas
- [ ] Rollback automático

## 🎉 Conclusión

**El sistema de actualización resuelve el problema fundamental:** los usuarios ahora pueden actualizar el framework sin perder sus customizaciones, datos o configuraciones.

**Resultado:**
- **Usuarios felices**: Actualizaciones seguras y fáciles
- **Desarrolladores contentos**: Distribución eficiente
- **Framework saludable**: Adopción continua de mejoras

---

*Sistema de actualización implementado: $(date)*  
*Framework Version: v1.0.0*  
*Status: Operativo*