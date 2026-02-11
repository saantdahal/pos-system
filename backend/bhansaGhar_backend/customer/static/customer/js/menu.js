let cart = {};
let currentCategory = "all";
let tableId = '{{ table.id|default:"" }}';
let pageType = '{{ page_type|default:"gated" }}'; // 'public' or 'gated'
let restaurantSlug = '{{ restaurant.slug|default:"" }}';
let tableNumber = '{{ table.number|default:"" }}';

// CSRF token
const csrfToken = "{{ csrf_token }}";

// Initialize
function init() {
  loadCart();
  updateCartDisplay();
  setupCategoryFilters();
}

// Category filtering
function setupCategoryFilters() {
  const tabs = document.querySelectorAll(".category-tab");
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      tabs.forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");
      currentCategory = tab.dataset.category;
      filterMenuItems();
    });
  });
}

function filterMenuItems() {
  const items = document.querySelectorAll(".menu-item");
  items.forEach((item) => {
    if (
      currentCategory === "all" ||
      item.dataset.category === currentCategory
    ) {
      item.style.display = "block";
    } else {
      item.style.display = "none";
    }
  });
}

// Cart functions
function loadCart() {
  const savedCart = localStorage.getItem("cart_" + tableId);
  if (savedCart) {
    cart = JSON.parse(savedCart);
  }
}

function saveCart() {
  localStorage.setItem("cart_" + tableId, JSON.stringify(cart));
}

function addToCart(button) {
  const itemId = button.getAttribute("data-item-id");
  const name = button.getAttribute("data-item-name");
  const price = parseFloat(button.getAttribute("data-item-price"));
  const image = button.getAttribute("data-item-image");

  if (!cart[itemId]) {
    cart[itemId] = {
      id: itemId,
      name: name,
      price: price,
      image: image,
      quantity: 0,
    };
  }
  cart[itemId].quantity += 1;
  saveCart();
  updateCartDisplay();
  showNotification("Added to cart!");
}

function updateQuantity(itemId, change) {
  if (cart[itemId]) {
    cart[itemId].quantity += change;
    if (cart[itemId].quantity <= 0) {
      delete cart[itemId];
    }
    saveCart();
    updateCartDisplay();
  }
}

function updateCartDisplay() {
  const count = Object.keys(cart).length;
  const totalItems = Object.values(cart).reduce(
    (sum, item) => sum + item.quantity,
    0,
  );

  // Update badges
  updateBadge("headerCartCount", totalItems);
  updateBadge("navCartCount", totalItems);

  // Update cart modal
  const cartItemsList = document.getElementById("cartItemsList");
  const emptyCart = document.getElementById("emptyCart");
  const cartItems = document.getElementById("cartItems");
  const cartTotal = document.getElementById("cartTotal");

  if (count === 0) {
    emptyCart.style.display = "block";
    cartItems.style.display = "none";
  } else {
    emptyCart.style.display = "none";
    cartItems.style.display = "block";

    let html = "";
    let total = 0;

    Object.values(cart).forEach((item) => {
      const subtotal = item.price * item.quantity;
      total += subtotal;
      html += `
                <div class="cart-item">
                    ${
                      item.image
                        ? `<img src="${item.image}" alt="${item.name}" class="cart-item-image">`
                        : '<div class="cart-item-image" style="background: var(--bg-secondary); display: flex; align-items: center; justify-content: center; font-size: 24px;">🍽️</div>'
                    }
                    <div class="cart-item-details">
                        <div class="cart-item-name">${item.name}</div>
                        <div class="cart-item-price">NPR ${item.price}</div>
                        <div class="quantity-controls">
                            <button class="quantity-btn" onclick="updateQuantity('${
                              item.id
                            }', -1)">-</button>
                            <span class="quantity-display">${
                              item.quantity
                            }</span>
                            <button class="quantity-btn" onclick="updateQuantity('${
                              item.id
                            }', 1)">+</button>
                        </div>
                    </div>
                </div>
            `;
    });

    cartItemsList.innerHTML = html;
    cartTotal.textContent = "NPR " + total.toFixed(2);
  }
}

function updateBadge(elementId, count) {
  const element = document.getElementById(elementId);
  if (count > 0) {
    element.textContent = count;
    element.style.display = "flex";
  } else {
    element.style.display = "none";
  }
}

function openCart() {
  document.getElementById("cartModal").classList.add("show");
}

function closeCart() {
  document.getElementById("cartModal").classList.remove("show");
}

function placeOrder() {
  if (Object.keys(cart).length === 0) {
    alert("Your cart is empty!");
    return;
  }

  const items = Object.values(cart).map((item) => ({
    id: item.id,
    quantity: item.quantity,
    notes: "",
  }));

  // Determine API endpoint based on page type
  let apiUrl;
  if (pageType === "public") {
    // Public mode - shouldn't reach here due to disabled button
    alert("Please scan QR code to place order");
    return;
  } else {
    // Gated mode - use the gated cart API
    apiUrl = `/restaurant/${restaurantSlug}/qr/${tableNumber}/api/cart/`;
  }

  fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRFToken": csrfToken,
    },
    body: JSON.stringify({
      action: "order",
      items: items,
      notes: "",
    }),
  })
    .then((response) => {
      if (response.status === 403) {
        // Session expired or invalid
        alert("Session expired. Please scan QR code again.");
        window.location.href = `/restaurant/${restaurantSlug}/`;
        return;
      }
      return response.json();
    })
    .then((data) => {
      if (data && data.order_id) {
        cart = {};
        saveCart();
        updateCartDisplay();
        closeCart();
        document.getElementById("statusModal").classList.add("show");
      } else {
        alert("Error placing order: " + (data?.error || "Unknown error"));
      }
    })
    .catch((error) => {
      console.error("Error:", error);
      alert("Error placing order. Please try again.");
    });
}

function closeStatus() {
  document.getElementById("statusModal").classList.remove("show");
  showOrdersPage();
}

function showMenuPage() {
  window.location.href = "/menu/" + (tableId || "");
}

function showOrdersPage() {
  window.location.href = "/orders/" + (tableId || "");
}

function showNotification(message) {
  // Simple notification
  const notification = document.createElement("div");
  notification.textContent = message;
  notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        background: var(--primary);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        z-index: 1001;
        animation: slideIn 0.3s ease-out;
    `;
  document.body.appendChild(notification);

  setTimeout(() => {
    notification.style.animation = "slideOut 0.3s ease-out";
    setTimeout(() => document.body.removeChild(notification), 300);
  }, 2000);
}

function getCSRFToken() {
  return csrfToken;
}

// Leave table function
function leaveTable() {
  if (
    confirm(
      "Are you sure you want to leave this table? Your cart will be cleared.",
    )
  ) {
    // Clear local cart
    localStorage.removeItem("cart_" + tableId);

    // Redirect to leave table URL
    window.location.href = "/leave/";
  }
}

// Session timeout check
function checkSessionTimeout() {
  const sessionStart = '{{ session_start|default:"" }}';
  if (sessionStart) {
    const startTime = new Date(sessionStart);
    const now = new Date();
    const diffHours = (now - startTime) / (1000 * 60 * 60);

    if (diffHours >= 1) {
      // Show prompt after 1 hour
      if (
        confirm(
          "You've been at this table for over an hour. Would you like to leave and free up the table for other customers?",
        )
      ) {
        leaveTable();
      } else {
        // Reset the timer by refreshing the page (which will update session_start)
        window.location.reload();
      }
    }
  }
}

// Check timeout every 5 minutes
setInterval(checkSessionTimeout, 5 * 60 * 1000);

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", init);
