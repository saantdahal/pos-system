let menuData = { categories: [] };

// State
let cart = {};
let currentCategory = "coffee";
let orders = [];
let ws = null;

// Initialize
function init() {
  fetchMenu();
  renderOrders();
  requestNotificationPermission();
  connectWebSocket();
}

// Fetch menu from server
async function fetchMenu() {
  try {
    // Replace with your server IP if testing on a real device
    // For local testing on the same machine, localhost is fine
    // But if accessing from phone, use the computer's IP
    const apiUrl = `http://${window.location.hostname}:8080/api/menu`;
    console.log("Fetching menu from:", apiUrl);

    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    menuData = data;

    // Set initial category if available
    if (menuData.categories && menuData.categories.length > 0) {
      currentCategory = menuData.categories[0].id;
    }

    renderCategories();
    renderMenu();
  } catch (error) {
    console.error("Failed to fetch menu:", error);
    // Show error state in UI
    document.getElementById("menuContainer").innerHTML = `
        <div style="text-align: center; padding: 40px;">
            <h3>⚠️ Failed to load menu</h3>
            <p>Please check if the server is running.</p>
            <button onclick="fetchMenu()" style="margin-top: 10px; padding: 8px 16px;">Retry</button>
        </div>
    `;
  }
}

// Show menu page
function showMenuPage() {
  document.getElementById("menuPage").classList.add("active");
  document.getElementById("ordersPage").classList.remove("active");
  document.querySelector(".categories").style.display = "block";

  // Update nav
  document
    .querySelectorAll(".nav-item")
    .forEach((item) => item.classList.remove("active"));
  document.querySelectorAll(".nav-item")[0].classList.add("active");
}

// Show orders page
function showOrdersPage() {
  document.getElementById("menuPage").classList.remove("active");
  document.getElementById("ordersPage").classList.add("active");
  document.querySelector(".categories").style.display = "none";

  // Update nav
  document
    .querySelectorAll(".nav-item")
    .forEach((item) => item.classList.remove("active"));
  document.querySelectorAll(".nav-item")[2].classList.add("active");

  renderOrders();
}

// Render categories
function renderCategories() {
  const tabsContainer = document.getElementById("categoryTabs");
  tabsContainer.innerHTML = menuData.categories
    .map(
      (cat) => `
        <button class="category-tab ${
          cat.id === currentCategory ? "active" : ""
        }" 
                onclick="switchCategory('${cat.id}')">
            ${cat.name}
        </button>
    `
    )
    .join("");
}

// Switch category
function switchCategory(categoryId) {
  currentCategory = categoryId;
  renderCategories();
  renderMenu();
}

// Render menu
function renderMenu() {
  const container = document.getElementById("menuContainer");
  const category = menuData.categories.find((c) => c.id === currentCategory);

  container.innerHTML = `
        <div class="category-section active">
            <h2 class="category-title">${category.name}</h2>
            <div class="menu-grid">
                ${category.items
                  .map(
                    (item) => `
                    <div class="menu-item">
                        <div class="item-image">${
                          item.image
                            ? `<img src="http://${window.location.hostname}:${window.location.port}${item.image}" style="width:100%;height:100%;object-fit:cover;" alt="${item.name}">`
                            : "🍽️"
                        }</div>
                        <div class="item-content">
                            <div class="item-header">
                                <div class="item-name">${item.name}</div>
                                <div class="item-price">${item.price.toFixed(
                                  2
                                )}</div>
                            </div>
                            <div class="item-description">${
                              item.description
                            }</div>
                            <div class="item-actions">
                                <button class="add-btn" onclick="addToCart('${
                                  item.id
                                }')">
                                    ➕ Add
                                </button>
                            </div>
                        </div>
                    </div>
                `
                  )
                  .join("")}
            </div>
        </div>
    `;
}

// Add to cart
function addToCart(itemId) {
  const item = menuData.categories
    .flatMap((c) => c.items)
    .find((i) => i.id === itemId);

  if (cart[itemId]) {
    cart[itemId].quantity++;
  } else {
    cart[itemId] = { ...item, quantity: 1 };
  }

  updateCartBadge();
  showNotification("Added to cart", `${item.name} added to your order`);
}

// Update cart badge
function updateCartBadge() {
  const count = Object.values(cart).reduce(
    (sum, item) => sum + item.quantity,
    0
  );

  // Update all cart count displays
  const displays = ["cartCount", "headerCartCount", "navCartCount"];
  displays.forEach((id) => {
    const element = document.getElementById(id);
    if (element) {
      element.textContent = count;
      element.style.display = count > 0 ? "flex" : "none";
    }
  });
}

// Update orders badge
function updateOrdersBadge() {
  const count = orders.length;

  const displays = ["headerOrdersCount", "navOrdersCount"];
  displays.forEach((id) => {
    const element = document.getElementById(id);
    if (element) {
      element.textContent = count;
      element.style.display = count > 0 ? "flex" : "none";
    }
  });
}

// Open cart
function openCart() {
  const modal = document.getElementById("cartModal");
  const body = document.getElementById("cartBody");

  const cartItems = Object.values(cart);

  if (cartItems.length === 0) {
    body.innerHTML = `
            <div class="empty-cart">
                <div class="empty-icon">🛒</div>
                <div>Your cart is empty</div>
            </div>
        `;
  } else {
    const subtotal = cartItems.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );

    body.innerHTML = `
            ${cartItems
              .map(
                (item) => `
                <div class="cart-item">
                    <div class="cart-item-info">
                        <div class="cart-item-name">${item.name}</div>
                        <div class="cart-item-price">$${item.price.toFixed(
                          2
                        )} each</div>
                    </div>
                    <div class="quantity-controls">
                        <button class="qty-btn" onclick="updateQuantity('${
                          item.id
                        }', -1)">−</button>
                        <div class="qty-value">${item.quantity}</div>
                        <button class="qty-btn" onclick="updateQuantity('${
                          item.id
                        }', 1)">+</button>
                    </div>
                </div>
            `
              )
              .join("")}
            
            <div class="order-summary">
                <div class="summary-row">
                    <span>Subtotal</span>
                    <span>$${subtotal.toFixed(2)}</span>
                </div>
                <div class="summary-row total">
                    <span>Total</span>
                    <span>$${subtotal.toFixed(2)}</span>
                </div>
            </div>
            
            <button class="checkout-btn" onclick="checkout()">
                Place Order
            </button>
        `;
  }

  modal.classList.add("active");
}

// Close cart
function closeCart() {
  document.getElementById("cartModal").classList.remove("active");
}

// Update quantity
function updateQuantity(itemId, change) {
  if (cart[itemId]) {
    cart[itemId].quantity += change;

    if (cart[itemId].quantity <= 0) {
      delete cart[itemId];
    }

    updateCartBadge();
    openCart();
  }
}

// Checkout
async function checkout() {
  const orderItems = Object.values(cart);
  const orderId = "ORD-" + Date.now();

  // Prepare payload matching server expectation
  const payload = {
    id: orderId,
    items: orderItems.map((item) => ({
      id: item.id,
      quantity: item.quantity,
      name: item.name,
    })),
    tableName: "Web Table", // You might want to make this dynamic later
  };

  try {
    const response = await fetch(
      `http://${window.location.hostname}:8080/api/order`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      }
    );

    if (!response.ok) {
      throw new Error("Failed to place order");
    }

    const result = await response.json();

    const newOrder = {
      id: result.orderId,
      items: orderItems,
      status: result.status,
      timestamp: new Date(result.receivedAt),
      total: orderItems.reduce(
        (sum, item) => sum + item.price * item.quantity,
        0
      ),
      notes: result.notes || [],
    };

    orders.unshift(newOrder);

    // Clear cart
    cart = {};
    updateCartBadge();
    updateOrdersBadge();
    closeCart();

    // Show orders page
    showOrdersPage();

    if (result.status === "Needs Confirmation") {
      showNotification(
        "Action Required",
        "Some items have limited stock. Please check your order."
      );
      showOrderDetail(result.orderId); // Auto open detail for confirmation
    } else {
      showNotification("Order placed!", `Order ${orderId} has been received`);
    }
  } catch (error) {
    console.error("Error placing order:", error);
    alert("Failed to place order. Please try again.");
  }
}

// Update order status
function updateOrderStatus(orderId, status) {
  const order = orders.find((o) => o.id === orderId);
  if (order) {
    order.status = status;
    renderOrders();
    showNotification(
      "Order update",
      `Order ${orderId} is ${status.toLowerCase()}`
    );
  }
}

// Render orders
function renderOrders() {
  const container = document.getElementById("orderList");

  if (orders.length === 0) {
    container.innerHTML = `
            <div class="no-orders">
                <div class="no-orders-icon">📋</div>
                <div class="no-orders-text">No orders yet</div>
                <div class="no-orders-subtext">Your orders will appear here</div>
            </div>
        `;
    return;
  }

  container.innerHTML = orders
    .map((order) => {
      const statusClass = order.status.toLowerCase().replace(" ", "-");
      const statusIcons = {
        Received: "📝",
        Preparing: "👨‍🍳",
        Ready: "✅",
        "Needs Confirmation": "⚠️",
        Cancelled: "❌",
      };

      return `
            <div class="order-card">
                <div class="order-header">
                    <div>
                        <div class="order-id">${order.id}</div>
                        <div class="order-time">${formatTime(
                          order.timestamp
                        )}</div>
                    </div>
                    <div class="order-status-badge ${statusClass}">
                        ${statusIcons[order.status]} ${order.status}
                    </div>
                </div>
                <div class="order-items-summary">
                    ${order.items.length} item${
        order.items.length !== 1 ? "s" : ""
      } • ${order.items.map((i) => `${i.quantity}x ${i.name}`).join(", ")}
                </div>
                <div class="order-footer">
                    <div class="order-total">Total: ${order.total.toFixed(
                      2
                    )}</div>
                    <button class="view-details-btn" onclick="showOrderDetail('${
                      order.id
                    }')">
                        View Details
                    </button>
                </div>
            </div>
        `;
    })
    .join("");
}

// Format time
function formatTime(date) {
  const now = new Date();
  const diff = now - date;
  const minutes = Math.floor(diff / 60000);

  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes} min ago`;

  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} hour${hours !== 1 ? "s" : ""} ago`;

  return date.toLocaleDateString();
}

// Show order detail
function showOrderDetail(orderId) {
  const order = orders.find((o) => o.id === orderId);
  if (!order) return;

  const modal = document.getElementById("statusModal");
  const body = document.getElementById("statusBody");

  const statusConfig = {
    Received: { icon: "📝", color: "var(--primary)" },
    Preparing: { icon: "👨‍🍳", color: "var(--warning)" },
    Ready: { icon: "✅", color: "var(--success)" },
    "Needs Confirmation": { icon: "⚠️", color: "purple" },
    Cancelled: { icon: "❌", color: "red" },
  };

  const config = statusConfig[order.status] || statusConfig["Received"];

  let statusDesc = "Your order has been received";
  if (order.status === "Ready") statusDesc = "Your order is ready for pickup!";
  else if (order.status === "Preparing")
    statusDesc = "We're preparing your order";
  else if (order.status === "Needs Confirmation")
    statusDesc = "Please confirm the available quantity";
  else if (order.status === "Cancelled")
    statusDesc = "This order was cancelled";

  let actionButtons = "";
  if (order.status === "Needs Confirmation") {
    actionButtons = `
        <div style="margin-top: 20px; padding: 15px; background: #fff3cd; border-radius: 8px; border: 1px solid #ffeeba;">
            <div style="font-weight: bold; margin-bottom: 8px; color: #856404;">⚠️ Stock Issue</div>
            <div style="margin-bottom: 15px; color: #856404;">
                ${
                  order.notes && order.notes.length > 0
                    ? order.notes.join("<br>")
                    : "Some items are not fully available."
                }
                <br>Do you want to proceed with the available quantity?
            </div>
            <div style="display: flex; gap: 10px;">
                <button onclick="confirmOrder('${
                  order.id
                }', 'confirm')" style="flex: 1; padding: 10px; background: var(--primary); color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 600;">
                    Update & Confirm
                </button>
                <button onclick="confirmOrder('${
                  order.id
                }', 'cancel')" style="flex: 1; padding: 10px; background: white; color: red; border: 1px solid red; border-radius: 6px; cursor: pointer; font-weight: 600;">
                    Cancel Order
                </button>
            </div>
        </div>
      `;
  }

  body.innerHTML = `
        <div class="order-detail-status">
            <div class="status-icon">${config.icon}</div>
            <div class="order-number">Order #${order.id}</div>
            <div class="status-text" style="color: ${config.color}">${
    order.status
  }</div>
            <div class="status-description">
                ${statusDesc}
            </div>
        </div>

        ${actionButtons}

        <div class="order-items-list">
            <div class="order-items-title">Order Items</div>
            ${order.items
              .map(
                (item) => `
                <div class="order-detail-item">
                    <div class="item-qty-name">
                        <span class="item-qty">${item.quantity}x</span>
                        ${item.name}
                    </div>
                    <div class="item-subtotal">${(
                      item.price * item.quantity
                    ).toFixed(2)}</div>
                </div>
            `
              )
              .join("")}
            <div class="order-detail-item" style="font-weight: 700; font-size: 16px; padding-top: 16px;">
                <div>Total</div>
                <div style="color: var(--primary);">${order.total.toFixed(
                  2
                )}</div>
            </div>
        </div>
        
        <div class="status-timeline">
            <div class="timeline-item ${
              ["Received", "Preparing", "Ready", "Completed"].includes(
                order.status
              )
                ? "completed"
                : ""
            }">
                <div class="timeline-dot ${
                  ["Received"].includes(order.status) ? "active" : ""
                }"></div>
                <div class="timeline-content">
                    <div class="timeline-label">Received</div>
                    <div class="timeline-time">Order confirmed</div>
                </div>
            </div>
            <div class="timeline-item ${
              ["Preparing", "Ready", "Completed"].includes(order.status)
                ? "completed"
                : ""
            }">
                <div class="timeline-dot ${
                  ["Preparing"].includes(order.status) ? "active" : ""
                }"></div>
                <div class="timeline-content">
                    <div class="timeline-label">Preparing</div>
                    <div class="timeline-time">Being prepared</div>
                </div>
            </div>
            <div class="timeline-item ${
              ["Ready", "Completed"].includes(order.status) ? "completed" : ""
            }">
                <div class="timeline-dot ${
                  order.status === "Ready" ? "active" : ""
                }"></div>
                <div class="timeline-content">
                    <div class="timeline-label">Ready</div>
                    <div class="timeline-time">Ready for pickup</div>
                </div>
            </div>
        </div>
    `;

  modal.classList.add("active");
}

async function confirmOrder(orderId, action) {
  try {
    const response = await fetch(
      `http://${window.location.hostname}:8080/api/order/${orderId}/confirm`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ action: action }),
      }
    );

    if (!response.ok) {
      throw new Error("Failed to update order");
    }

    const result = await response.json();

    // Update local order state
    const order = orders.find((o) => o.id === orderId);
    if (order) {
      if (result.status === "Cancelled") {
        order.status = "Cancelled";
      } else {
        order.status = result.status;
        // Update items and total if provided
        if (result.items) {
          order.items = result.items;
        }
        if (result.total) {
          order.total = result.total;
        }
      }
      renderOrders();
      closeStatus();
      showNotification("Order Updated", `Order ${orderId} is ${order.status}`);
    }
  } catch (error) {
    console.error("Error confirming order:", error);
    alert("Failed to update order. Please try again.");
  }
}

// Send order
function sendOrder(order) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ type: "order", data: order }));
  }
}

// WebSocket connection
function connectWebSocket() {
  // Use the same hostname as the page, or fallback to localhost
  const host = window.location.hostname || "localhost";
  const wsUrl = `ws://${host}:8080/ws`;

  try {
    ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log("Connected to server");
    };

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);

      if (message.type === "status_update") {
        updateOrderStatus(message.orderId, message.status);
      }
    };

    ws.onerror = () => {
      console.log("WebSocket error - falling back to polling");
    };

    ws.onclose = () => {
      console.log("Disconnected from server");
      // Reconnect after 5 seconds
      setTimeout(connectWebSocket, 5000);
    };
  } catch (error) {
    console.log("WebSocket not available");
  }
}

// Notifications
function requestNotificationPermission() {
  if ("Notification" in window && Notification.permission === "default") {
    Notification.requestPermission();
  }
}

function showNotification(title, body) {
  if ("Notification" in window && Notification.permission === "granted") {
    new Notification(title, {
      body: body,
      icon: "🍽️",
      badge: "🍽️",
    });
  }
}

// Close status
function closeStatus() {
  document.getElementById("statusModal").classList.remove("active");
}

// Close modals on background click
document.getElementById("cartModal").addEventListener("click", (e) => {
  if (e.target.id === "cartModal") closeCart();
});

document.getElementById("statusModal").addEventListener("click", (e) => {
  if (e.target.id === "statusModal") closeStatus();
});

// Initialize app
init();
