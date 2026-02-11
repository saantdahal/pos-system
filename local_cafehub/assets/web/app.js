let menuData = { categories: [] };

// State
let cart = {};
let currentCategory = "coffee";
let orders = [];
let ws = null;
let tables = [];
let selectedTable = null;

// Initialize
function init() {
  loadCartFromStorage();
  loadOrdersFromStorage();
  fetchMenu();
  fetchTables();
  renderOrders();
  requestNotificationPermission();
  connectWebSocket();
  startOrderStatusPolling();
}

// Fetch menu from server
async function fetchMenu() {
  try {
    const port = window.location.port || 8080;
    const apiUrl = `http://${window.location.hostname}:${port}/api/menu`;
    console.log("Fetching menu from:", apiUrl);

    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    menuData = data || { categories: [] };

    // Set initial category if available
    if (menuData.categories && menuData.categories.length > 0) {
      currentCategory = menuData.categories[0].id;
    } else {
      currentCategory = null;
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
            <p style="font-size: 12px; color: grey;">${error.message}</p>
            <button onclick="fetchMenu()" style="margin-top: 10px; padding: 8px 16px;">Retry</button>
        </div>
    `;
  }
}

// Fetch tables from server
async function fetchTables() {
  try {
    const port = window.location.port || 8080;
    const apiUrl = `http://${window.location.hostname}:${port}/api/tables`;
    console.log("Fetching tables from:", apiUrl);

    const response = await fetch(apiUrl);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    tables = data.tables || [];
    console.log("Tables loaded:", tables);
  } catch (error) {
    console.error("Failed to fetch tables:", error);
    tables = [];
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

  if (!menuData.categories || menuData.categories.length === 0) {
    container.innerHTML = `
        <div class="category-section active">
             <div style="text-align: center; padding: 40px; color: var(--text-color);">
                 <div style="font-size: 48px; margin-bottom: 16px;">🍽️</div>
                 <h3>No Menu Available</h3>
                 <p>There are no items to display yet.</p>
            </div>
        </div>
    `;
    return;
  }

  let category = menuData.categories.find((c) => c.id === currentCategory);

  // Fallback if current category is invalid
  if (!category && menuData.categories.length > 0) {
    category = menuData.categories[0];
    currentCategory = category.id;
    renderCategories(); // Update tabs
  }

  if (!category) return; // Should not happen due to check above

  container.innerHTML = `
        <div class="category-section active">
            <h2 class="category-title">${category.name}</h2>
            <div class="menu-grid">
                ${
                  category.items && category.items.length > 0
                    ? category.items
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
                        .join("")
                    : `<div style="grid-column: 1/-1; text-align: center; padding: 20px;">No items in this category</div>`
                }
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
  saveCartToStorage();
  showSnackbar(`${item.name} added to cart`);
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
                         <div class="cart-item-price">Rs.${item.price.toFixed(
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
                    <span>Rs.${subtotal.toFixed(2)}</span>
                </div>
                <div class="summary-row total">
                    <span>Total</span>
                    <span>Rs.${subtotal.toFixed(2)}</span>
                </div>
            </div>
            
            ${
              tables.length > 0
                ? `
              <div style="margin: 20px 0; padding-top: 20px; border-top: 1px solid var(--border-color);">
                <div style="font-weight: 600; margin-bottom: 12px; font-size: 14px; color: var(--text-color);">Select Table <span style="color: red;">*</span></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                  ${tables
                    .map(
                      (table) => `
                    <button 
                      class="table-chip ${
                        selectedTable === table.id ? "active" : ""
                      }" 
                      onclick="selectTable('${table.id}')"
                      style="padding: 10px 16px; border: 2px solid ${
                        selectedTable === table.id
                          ? "var(--primary)"
                          : "var(--border-color)"
                      }; background: ${
                        selectedTable === table.id
                          ? "var(--primary)"
                          : "transparent"
                      }; color: ${
                        selectedTable === table.id
                          ? "white"
                          : "var(--text-color)"
                      }; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 500;"
                    >
                      Table ${table.tableNumber}
                    </button>
                  `
                    )
                    .join("")}
                </div>
              </div>
            `
                : ""
            }
            
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

// Select table
function selectTable(tableId) {
  selectedTable = tableId;
  openCart(); // Re-render cart to show updated selection
}

// Update quantity
function updateQuantity(itemId, change) {
  if (cart[itemId]) {
    cart[itemId].quantity += change;

    if (cart[itemId].quantity <= 0) {
      delete cart[itemId];
    }

    saveCartToStorage();
    updateCartBadge();
    openCart();
  }
}

// Checkout
function checkout() {
  // Validate table selection
  // if (tables.length > 0 && !selectedTable) {
  //   showSnackbar("Please select a table before placing your order", "error");
  //   return;
  // }

  const orderItems = Object.values(cart);
  const orderId = "ORD-" + Date.now();
  const total = orderItems.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  const newOrder = {
    id: orderId,
    items: orderItems,
    status: "Received",
    timestamp: new Date(),
    total: total,
    tableId: selectedTable,
    tableName: selectedTable
      ? `Table ${tables.find((t) => t.id === selectedTable)?.tableNumber || ""}`
      : null,
  };

  orders.unshift(newOrder);
  saveOrdersToStorage();

  // Send order to server
  sendOrderToServer(newOrder);

  // Clear cart and reset table selection
  cart = {};
  selectedTable = null;
  saveCartToStorage();
  updateCartBadge();
  updateOrdersBadge();
  closeCart();

  // Show orders page
  showOrdersPage();
  showSnackbar(`Order ${orderId} placed successfully!`, "success");
}

// Update order status
function updateOrderStatus(orderId, status, items, total) {
  const order = orders.find((o) => o.id === orderId);
  if (order) {
    order.status = status;
    if (items) order.items = items;
    if (total) order.total = total;

    // Clear cart if order is completed and it's the most recent order
    if (status === "Completed" && order.id === orders[0]?.id) {
      cart = {};
      selectedTable = null;
      saveCartToStorage();
      updateCartBadge();
    }

    saveOrdersToStorage();
    renderOrders();
    showSnackbar(`Order ${orderId} is now ${status}`, "info");
  }
}

// Poll for order status updates from server
async function pollOrderStatus(orderId) {
  try {
    const port = window.location.port || 8080;
    const apiUrl = `http://${window.location.hostname}:${port}/api/order/${orderId}/status`;
    const response = await fetch(apiUrl);

    if (!response.ok) return;

    const data = await response.json();

    const order = orders.find((o) => o.id === orderId);
    if (order) {
      let hasChanges = false;

      // Check status change
      if (order.status !== data.status) {
        order.status = data.status;
        hasChanges = true;
        showSnackbar(`Order ${orderId} is now ${data.status}`, "info");
      }

      // Update items and notes if provided (for negotiation updates)
      if (data.items) {
        // Check if items actually changed to avoid unnecessary re-renders?
        // For simplicity, just update.
        order.items = data.items;
        order.notes = data.notes || [];
        order.total = data.total || order.total;
        hasChanges = true;
      }

      if (hasChanges) {
        saveOrdersToStorage();
        renderOrders();

        // If the modal for this order is open, re-render it
        const modal = document.getElementById("statusModal");
        const orderNumberEl = modal.querySelector(".order-number");
        if (
          modal.classList.contains("active") &&
          orderNumberEl &&
          orderNumberEl.textContent.includes(orderId)
        ) {
          showOrderDetail(orderId);
        }
      }
    }
  } catch (error) {
    console.error("Failed to poll order status:", error);
  }
}

// Start polling for all active orders
function startOrderStatusPolling() {
  setInterval(() => {
    // Poll status for non-completed orders
    orders
      .filter((order) => order.status !== "Completed")
      .forEach((order) => pollOrderStatus(order.id));
  }, 5000); // Poll every 5 seconds
}

// Close status modal
function closeStatusModal() {
  document.getElementById("statusModal").classList.remove("active");
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
        Completed: "🏁",
      };

      const icon = statusIcons[order.status] || "❓";

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
                        ${icon} ${order.status}
                    </div>
                </div>
                ${
                  order.tableName
                    ? `
                  <div style="padding: 8px 0; color: var(--primary); font-size: 14px; font-weight: 600;">
                    📍 ${order.tableName}
                  </div>
                `
                    : ""
                }
                <div class="order-items-summary">
                    ${order.items.length} item${
        order.items.length !== 1 ? "s" : ""
      } • ${order.items.map((i) => `${i.quantity}x ${i.name}`).join(", ")}
                </div>
                <div class="order-footer">
                    <div class="order-total">Total: Rs.${order.total.toFixed(
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
    "Needs Confirmation": { icon: "⚠️", color: "var(--error)" },
    Cancelled: { icon: "❌", color: "var(--text-color)" },
    Completed: { icon: "🏁", color: "var(--text-color)" },
  };

  const config = statusConfig[order.status] || {
    icon: "❓",
    color: "var(--text-color)",
  };

  let actionButtons = "";
  let statusMessage = "";

  // Check if we actually have proposed items to show
  const hasProposals = order.items.some(
    (i) => i.proposedQuantity !== undefined && i.proposedQuantity !== null
  );

  if (order.status === "Needs Confirmation") {
    if (hasProposals) {
      statusMessage = `
          <div style="background-color: rgba(255, 152, 0, 0.1); border-left: 4px solid var(--warning); padding: 12px; margin-top: 12px; border-radius: 4px;">
            <div style="font-weight: bold; color: var(--warning); margin-bottom: 4px;">Action Required</div>
            <div style="font-size: 14px; color: var(--text-color);">
              Some items in your order are unavailable in the requested quantity. 
              The admin has proposed changes (highlighted below). 
              Please <strong>Accept</strong> the proposal to proceed or <strong>Cancel</strong> the order.
            </div>
          </div>
        `;

      actionButtons = `
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; gap: 12px; justify-content: flex-end;">
                <button onclick="confirmOrder('${order.id}', 'cancel')" 
                  style="padding: 12px 24px; border: 1px solid var(--error); background: white; color: var(--error); border-radius: 8px; cursor: pointer; font-weight: 600; transition: all 0.2s;">
                    Cancel Order
                </button>
                <button onclick="confirmOrder('${order.id}', 'confirm')" 
                  style="padding: 12px 24px; border: none; background: var(--primary); color: white; border-radius: 8px; cursor: pointer; font-weight: 600; box-shadow: 0 2px 8px rgba(0,0,0,0.2); transition: all 0.2s;">
                    Accept Proposal
                </button>
            </div>
        `;
    } else {
      // Status is Needs Confirmation but we don't have proposals yet (maybe syncing)
      statusMessage = `
          <div style="background-color: rgba(33, 150, 243, 0.1); border-left: 4px solid var(--info); padding: 12px; margin-top: 12px; border-radius: 4px;">
            <div style="font-weight: bold; color: var(--info); margin-bottom: 4px;">Updating...</div>
            <div style="font-size: 14px; color: var(--text-color);">
              Fetching proposal details from admin...
            </div>
          </div>
        `;
    }
  } else {
    statusMessage = `
      <div class="status-description">
          ${
            order.status === "Ready"
              ? "Your order is ready for pickup!"
              : order.status === "Preparing"
              ? "We're preparing your order"
              : order.status === "Cancelled"
              ? "This order has been cancelled."
              : "Your order has been received"
          }
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
            ${statusMessage}
            ${
              order.notes && order.notes.length > 0
                ? `<div style="margin-top: 12px; font-size: 13px; color: var(--text-color); opacity: 0.8; background: rgba(0,0,0,0.05); padding: 8px; border-radius: 4px;">
                    <strong>Note:</strong> ${order.notes.join("<br>")}
                   </div>`
                : ""
            }
        </div>

        <div class="order-items-list">
            <div class="order-items-title">Order Items</div>
            ${order.items
              .map((item) => {
                const hasProposal =
                  item.proposedQuantity !== undefined &&
                  item.proposedQuantity !== null;
                return `
                <div class="order-detail-item">
                    <div class="item-qty-name">
                        <span class="item-qty" style="${
                          hasProposal
                            ? "text-decoration: line-through; opacity: 0.5; margin-right: 4px;"
                            : ""
                        }">${item.quantity}x</span>
                        ${
                          hasProposal
                            ? `<span class="item-qty" style="color: var(--primary); font-weight: bold;">${item.proposedQuantity}x</span>`
                            : ""
                        }
                        ${item.name}
                    </div>
                    <div class="item-subtotal">Rs.${(
                      item.price *
                      (hasProposal ? item.proposedQuantity : item.quantity)
                    ).toFixed(2)}</div>
                </div>
            `;
              })
              .join("")}
            <div class="order-detail-item" style="font-weight: 700; font-size: 16px; padding-top: 16px;">
                <div>Total</div>
                <div style="color: var(--primary);">Rs.${order.total.toFixed(
                  2
                )}</div>
            </div>
        </div>
        
        ${actionButtons}
        
        <div class="status-timeline">
            <div class="timeline-item ${
              ["Received", "Preparing", "Ready", "Completed"].includes(
                order.status
              )
                ? "completed"
                : ""
            }">
                <div class="timeline-dot ${
                  order.status === "Received" ? "active" : ""
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
                  order.status === "Preparing" ? "active" : ""
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
    const port = window.location.port || 8080;
    const apiUrl = `http://${window.location.hostname}:${port}/api/order/${orderId}/confirm`;
    const response = await fetch(apiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ action }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    console.log("Order confirmed/cancelled:", result);

    // Close modal
    closeStatus();

    // Update local state immediately (will also be updated by websocket/polling)
    updateOrderStatus(orderId, result.status);

    showSnackbar(
      action === "confirm"
        ? "Order confirmed successfully!"
        : "Order cancelled",
      action === "confirm" ? "success" : "info"
    );
  } catch (error) {
    console.error("Failed to confirm order:", error);
    showSnackbar("Failed to update order", "error");
  }
}

// Send order to server via API
async function sendOrderToServer(order) {
  try {
    const apiUrl = `http://${window.location.hostname}:8080/api/order`;
    const response = await fetch(apiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(order),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    console.log("Order sent successfully:", result);
  } catch (error) {
    console.error("Failed to send order:", error);
    showSnackbar("Failed to send order to server", "error");
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
        updateOrderStatus(
          message.orderId,
          message.status,
          message.items,
          message.total
        );
      } else if (message.type === "order") {
        // Handle incoming order updates from server
        console.log("Order update received:", message.data);
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

// LocalStorage functions
function saveCartToStorage() {
  localStorage.setItem("cafeCart", JSON.stringify(cart));
  localStorage.setItem("cafeSelectedTable", selectedTable || "");
}

function loadCartFromStorage() {
  const savedCart = localStorage.getItem("cafeCart");
  const savedTable = localStorage.getItem("cafeSelectedTable");

  if (savedCart) {
    try {
      cart = JSON.parse(savedCart);
      updateCartBadge();
    } catch (e) {
      console.error("Failed to load cart:", e);
      cart = {};
    }
  }

  if (savedTable) {
    selectedTable = savedTable || null;
  }
}

function saveOrdersToStorage() {
  // Only save last 20 orders
  const ordersToSave = orders.slice(0, 20);
  localStorage.setItem("cafeOrders", JSON.stringify(ordersToSave));
}

function loadOrdersFromStorage() {
  const savedOrders = localStorage.getItem("cafeOrders");

  if (savedOrders) {
    try {
      const now = new Date();
      const twelveHoursAgo = new Date(now.getTime() - 12 * 60 * 60 * 1000);

      orders = JSON.parse(savedOrders)
        .map((order) => ({
          ...order,
          timestamp: new Date(order.timestamp),
        }))
        .filter((order) => order.timestamp > twelveHoursAgo);

      // Update storage to remove old orders
      localStorage.setItem("cafeOrders", JSON.stringify(orders));

      updateOrdersBadge();
    } catch (e) {
      console.error("Failed to load orders:", e);
      orders = [];
    }
  }
}

// Show snackbar notification
function showSnackbar(message, type = "success") {
  // Remove existing snackbar if any
  const existing = document.querySelector(".snackbar");
  if (existing) existing.remove();

  const snackbar = document.createElement("div");
  snackbar.className = "snackbar";
  snackbar.textContent = message;

  // Set color based on type
  const colors = {
    success: "#4CAF50",
    error: "#f44336",
    info: "#2196F3",
    warning: "#ff9800",
  };

  snackbar.style.cssText = `
    position: fixed;
    bottom: 80px;
    left: 50%;
    transform: translateX(-50%);
    background: ${colors[type] || colors.success};
    color: white;
    padding: 16px 24px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    z-index: 10000;
    font-size: 14px;
    font-weight: 500;
    animation: slideUp 0.3s ease-out;
  `;

  document.body.appendChild(snackbar);

  // Auto remove after 3 seconds
  setTimeout(() => {
    snackbar.style.animation = "slideDown 0.3s ease-out";
    setTimeout(() => snackbar.remove(), 300);
  }, 3000);
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
