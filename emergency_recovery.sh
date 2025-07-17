#!/bin/bash

# Emergency Recovery Script
# Use this if circuit breakers malfunction or block legitimate operations

echo "🚨 Emergency Recovery Mode"
echo "=========================="

# Restore original ai-dev
if [ -f "ai-dev.original" ]; then
    echo "🔄 Restoring original ai-dev..."
    cp ai-dev.original ai-dev
    chmod +x ai-dev
    echo "✅ Original ai-dev restored"
else
    echo "❌ Original ai-dev not found"
fi

# Clear all circuit breakers
echo "🔄 Clearing all circuit breakers..."
rm -rf .ai_workflow/circuit_breakers/

# Clear any emergency stops
echo "🔄 Clearing emergency stops..."
if [ -f ".ai_workflow/scripts/simple_circuit_breaker.sh" ]; then
    .ai_workflow/scripts/simple_circuit_breaker.sh clear
fi

# Kill any hanging processes
echo "🔄 Cleaning up processes..."
pkill -f "ai-dev" 2>/dev/null || true
pkill -f ".ai_workflow" 2>/dev/null || true

# Restart circuit breaker system
echo "🔄 Reinitializing circuit breakers..."
if [ -f ".ai_workflow/scripts/simple_circuit_breaker.sh" ]; then
    .ai_workflow/scripts/simple_circuit_breaker.sh init
fi

echo "✅ Emergency recovery completed"
echo "📋 Framework should now be fully operational"
echo "🔧 To re-enable protection, run: mv ai-dev.protected ai-dev"