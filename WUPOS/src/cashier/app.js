// WUPOS Cashier Interface - Main Application Logic

// Application state
let currentTransaction = {
    items: [],
    subtotal: 0,
    tax: 0,
    total: 0
};

// Sample product database (in real app, this would come from backend)
const productDatabase = {
    "123456789": { name: "Coffee Mug", price: 12.99 },
    "987654321": { name: "T-Shirt", price: 24.99 },
    "456789123": { name: "Notebook", price: 8.50 },
    "789123456": { name: "Pen", price: 2.99 }
};

// Initialize application
document.addEventListener('DOMContentLoaded', function() {
    initializeInterface();
    setupEventListeners();
    updateClock();
    setInterval(updateClock, 1000);
});

function initializeInterface() {
    // Focus on barcode input
    document.getElementById('barcode-input').focus();
    
    // Clear any existing transaction
    updateCartDisplay();
}

function setupEventListeners() {
    // Barcode input handling
    const barcodeInput = document.getElementById('barcode-input');
    barcodeInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            processBarcode(this.value);
            this.value = '';
        }
    });
    
    // Scan button
    document.getElementById('scan-btn').addEventListener('click', function() {
        const barcode = document.getElementById('barcode-input').value;
        if (barcode) {
            processBarcode(barcode);
            document.getElementById('barcode-input').value = '';
        }
    });
    
    // Product search
    const searchInput = document.getElementById('product-search');
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchProduct(this.value);
            this.value = '';
        }
    });
    
    document.getElementById('search-btn').addEventListener('click', function() {
        const searchTerm = document.getElementById('product-search').value;
        if (searchTerm) {
            searchProduct(searchTerm);
            document.getElementById('product-search').value = '';
        }
    });
}

function processBarcode(barcode) {
    const product = productDatabase[barcode];
    if (product) {
        addItemToCart(barcode, product);
        showNotification(`Added ${product.name} to cart`);
    } else {
        showNotification(`Product not found: ${barcode}`, 'error');
    }
}

function searchProduct(searchTerm) {
    const foundProducts = Object.entries(productDatabase).filter(([barcode, product]) => 
        product.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    if (foundProducts.length === 1) {
        const [barcode, product] = foundProducts[0];
        addItemToCart(barcode, product);
        showNotification(`Added ${product.name} to cart`);
    } else if (foundProducts.length > 1) {
        showProductSelection(foundProducts);
    } else {
        showNotification(`No products found for: ${searchTerm}`, 'error');
    }
}

function addItemToCart(barcode, product) {
    // Check if item already exists in cart
    const existingItem = currentTransaction.items.find(item => item.barcode === barcode);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        currentTransaction.items.push({
            barcode: barcode,
            name: product.name,
            price: product.price,
            quantity: 1
        });
    }
    
    calculateTotals();
    updateCartDisplay();
    
    // Return focus to barcode input
    document.getElementById('barcode-input').focus();
}

function calculateTotals() {
    currentTransaction.subtotal = currentTransaction.items.reduce((sum, item) => 
        sum + (item.price * item.quantity), 0
    );
    
    // Calculate tax (8.5% in this example)
    currentTransaction.tax = currentTransaction.subtotal * 0.085;
    currentTransaction.total = currentTransaction.subtotal + currentTransaction.tax;
}

function updateCartDisplay() {
    const cartContainer = document.getElementById('cart-items');
    
    if (currentTransaction.items.length === 0) {
        cartContainer.innerHTML = '<p style="text-align: center; color: #666; padding: 2rem;">No items in cart</p>';
    } else {
        cartContainer.innerHTML = currentTransaction.items.map(item => `
            <div class="cart-item">
                <div>
                    <strong>${item.name}</strong><br>
                    <small>$${item.price.toFixed(2)} x ${item.quantity}</small>
                </div>
                <div style="text-align: right;">
                    <div>$${(item.price * item.quantity).toFixed(2)}</div>
                    <button onclick="removeItem('${item.barcode}')" style="background: #e74c3c; color: white; border: none; padding: 2px 6px; border-radius: 3px; cursor: pointer;">Remove</button>
                </div>
            </div>
        `).join('');
    }
    
    // Update totals display
    document.getElementById('subtotal').textContent = currentTransaction.subtotal.toFixed(2);
    document.getElementById('tax').textContent = currentTransaction.tax.toFixed(2);
    document.getElementById('total').textContent = currentTransaction.total.toFixed(2);
}

function removeItem(barcode) {
    currentTransaction.items = currentTransaction.items.filter(item => item.barcode !== barcode);
    calculateTotals();
    updateCartDisplay();
}

function processPayment(method) {
    if (currentTransaction.items.length === 0) {
        showNotification('No items in cart', 'error');
        return;
    }
    
    const total = currentTransaction.total;
    
    switch(method) {
        case 'cash':
            processCashPayment(total);
            break;
        case 'card':
            processCardPayment(total);
            break;
        case 'mobile':
            processMobilePayment(total);
            break;
    }
}

function processCashPayment(total) {
    const amountReceived = prompt(`Total: $${total.toFixed(2)}\\nEnter cash amount received:`);
    if (amountReceived && parseFloat(amountReceived) >= total) {
        const change = parseFloat(amountReceived) - total;
        showNotification(`Payment successful! Change: $${change.toFixed(2)}`);
        completeTransaction();
    } else {
        showNotification('Insufficient cash amount', 'error');
    }
}

function processCardPayment(total) {
    // Simulate card processing
    showNotification('Processing card payment...');
    setTimeout(() => {
        showNotification(`Card payment successful! Total: $${total.toFixed(2)}`);
        completeTransaction();
    }, 2000);
}

function processMobilePayment(total) {
    // Simulate mobile payment processing
    showNotification('Waiting for mobile payment...');
    setTimeout(() => {
        showNotification(`Mobile payment successful! Total: $${total.toFixed(2)}`);
        completeTransaction();
    }, 3000);
}

function completeTransaction() {
    // In real app, this would save to database and print receipt
    console.log('Transaction completed:', currentTransaction);
    
    // Clear current transaction
    clearTransaction();
    
    showNotification('Transaction completed successfully!');
}

function clearTransaction() {
    currentTransaction = {
        items: [],
        subtotal: 0,
        tax: 0,
        total: 0
    };
    updateCartDisplay();
    document.getElementById('barcode-input').focus();
}

function updateClock() {
    const now = new Date();
    const timeString = now.toLocaleTimeString();
    const timeElement = document.getElementById('current-time');
    if (timeElement) {
        timeElement.textContent = timeString;
    }
}

function showNotification(message, type = 'success') {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 1rem 2rem;
        border-radius: 4px;
        color: white;
        font-weight: bold;
        z-index: 1000;
        background-color: ${type === 'error' ? '#e74c3c' : '#27ae60'};
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        document.body.removeChild(notification);
    }, 3000);
}

function showProductSelection(products) {
    // Simple product selection for multiple matches
    const productList = products.map(([barcode, product], index) => 
        `${index + 1}. ${product.name} - $${product.price}`
    ).join('\\n');
    
    const selection = prompt(`Multiple products found:\\n${productList}\\n\\nEnter number to select:`);
    const selectedIndex = parseInt(selection) - 1;
    
    if (selectedIndex >= 0 && selectedIndex < products.length) {
        const [barcode, product] = products[selectedIndex];
        addItemToCart(barcode, product);
        showNotification(`Added ${product.name} to cart`);
    }
}