// Custom JS for Admin Dashboard
// Extracted from dashboard.html

// Chart Colors
const colors = {
  primary: "#6366f1",
  secondary: "#10b981",
  danger: "#ef4444",
  warning: "#f59e0b",
  info: "#3b82f6",
  light: "#e5e7eb",
  purple: "#8b5cf6",
};

// Chart instances for updates
let revenueChart, statusChart, hourlyChart, bargainChart;

// Parse initial chart data
let chartData;
try {
  chartData = JSON.parse(document.getElementById("chart-data").textContent);
} catch (e) {
  console.error("Error parsing chart data:", e);
  chartData = {};
}

// Initialize Charts
function initCharts() {
  // Revenue Chart
  const revenueCtx = document.getElementById("revenueChart").getContext("2d");
  revenueChart = new Chart(revenueCtx, {
    type: "line",
    data: {
      labels: chartData.revenueLabels || [],
      datasets: [
        {
          label: "Revenue (Rs.)",
          data: chartData.revenueData || [],
          borderColor: colors.primary,
          backgroundColor: "rgba(99, 102, 241, 0.1)",
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          pointRadius: 3,
          pointBackgroundColor: colors.primary,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, ticks: { callback: (v) => "Rs. " + v } },
        x: { ticks: { maxTicksLimit: 10 } },
      },
    },
  });

  // Order Status Chart
  const statusCtx = document.getElementById("statusChart").getContext("2d");
  statusChart = new Chart(statusCtx, {
    type: "doughnut",
    data: {
      labels: [
        "Pending",
        "Preparing",
        "Bargain",
        "Ready",
        "Served",
        "Cancelled",
      ],
      datasets: [
        {
          data: [
            chartData.orderPending || 0,
            chartData.orderPreparing || 0,
            chartData.orderBargain || 0,
            chartData.orderReady || 0,
            chartData.orderServed || 0,
            chartData.orderCancelled || 0,
          ],
          backgroundColor: [
            colors.warning,
            colors.info,
            colors.purple,
            colors.primary,
            colors.secondary,
            colors.danger,
          ],
          borderColor: "#fff",
          borderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
    },
  });

  // Hourly Distribution Chart
  const hourlyCtx = document.getElementById("hourlyChart").getContext("2d");
  hourlyChart = new Chart(hourlyCtx, {
    type: "bar",
    data: {
      labels: chartData.hourlyLabels || [],
      datasets: [
        {
          label: "Orders",
          data: chartData.hourlyData || [],
          backgroundColor: colors.primary,
          borderRadius: 4,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { maxTicksLimit: 12 } },
      },
    },
  });

  // Bargain Chart
  const bargainCtx = document.getElementById("bargainChart").getContext("2d");
  bargainChart = new Chart(bargainCtx, {
    type: "pie",
    data: {
      labels: ["Accepted", "Rejected", "Pending"],
      datasets: [
        {
          data: [
            chartData.bargainAccepted || 0,
            chartData.bargainRejected || 0,
            chartData.bargainPending || 0,
          ],
          backgroundColor: [colors.secondary, colors.danger, colors.warning],
          borderColor: "#fff",
          borderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { position: "bottom" } },
    },
  });
}

// Initialize on load
document.addEventListener("DOMContentLoaded", function () {
  initCharts();
});

// Restaurant Selection Handler - Redirects to dedicated restaurant dashboard
function handleRestaurantChange(restaurantId) {
  if (restaurantId) {
    // Redirect to new dedicated restaurant dashboard
    window.location.href = `/admin/restaurant/${restaurantId}/`;
  } else {
    // Stay on all restaurants overview
    updateViewIndicator(null);
  }
}

// Filter Restaurants by Search and Status
function filterRestaurants() {
  const searchInput = document.getElementById("restaurantSearch");
  const statusFilter = document.getElementById("statusFilter");
  const restaurantCards = document.querySelectorAll(".restaurant-card");

  if (!searchInput || !statusFilter) return;

  const searchTerm = searchInput.value.toLowerCase();
  const statusValue = statusFilter.value;

  restaurantCards.forEach((card) => {
    const name = card
      .querySelector("h3")
      .textContent.toLowerCase();
    const statusBadge = card.querySelector(".badge");
    const isActive = statusBadge && statusBadge.classList.contains("active");

    // Check search match
    const matchesSearch = name.includes(searchTerm);

    // Check status match
    let matchesStatus = true;
    if (statusValue === "active") {
      matchesStatus = isActive;
    } else if (statusValue === "inactive") {
      matchesStatus = !isActive;
    }

    // Show/hide card
    if (matchesSearch && matchesStatus) {
      card.style.display = "";
    } else {
      card.style.display = "none";
    }
  });
}

// Update View Indicator
function updateViewIndicator(restaurantName) {
  const indicator = document.getElementById("currentViewIndicator");
  if (!indicator) return;

  if (restaurantName) {
    indicator.innerHTML = `
            <div class="view-badge single-restaurant">
                <span class="icon">🏪</span>
                <span class="text">Viewing: <strong>${restaurantName}</strong></span>
            </div>
        `;
  } else {
    indicator.innerHTML = `
            <div class="view-badge all-restaurants">
                <span class="icon">📊</span>
                <span class="text">Viewing: <strong>All Restaurants Overview</strong></span>
                <span class="count">({{ restaurant_stats|length }} restaurants)</span>
            </div>
        `;
  }
}

// Select Restaurant Card - Redirects to restaurant dashboard
function selectRestaurant(restaurantId) {
  window.location.href = `/admin/restaurant/${restaurantId}/`;
}

// Fetch Restaurant-Specific Data (for AJAX updates on overview page)
async function fetchRestaurantData(restaurantId) {
  showLoading();
  try {
    const response = await fetch(
      `/admin/api/restaurant-stats/${restaurantId}/`,
    );
    const data = await response.json();

    if (data.error) {
      alert(data.error);
      return;
    }

    updateDashboardWithData(data);
    updateViewIndicator(data.restaurant_name);
    updateLastUpdated();
  } catch (error) {
    console.error("Error fetching restaurant data:", error);
    alert("Failed to fetch restaurant data");
  } finally {
    hideLoading();
  }
}

// Refresh Dashboard
async function refreshDashboard() {
  showLoading();
  try {
    const response = await fetch("/admin/api/dashboard-data/");
    const data = await response.json();
    updateDashboardWithData(data);
    // updateLastUpdated(); // Removed - now using server time from API
  } catch (error) {
    console.error("Error refreshing dashboard:", error);
  } finally {
    hideLoading();
  }
}

// Update Dashboard with API Data
function updateDashboardWithData(data) {
  // Update last updated time if provided
  if (data.last_updated) {
    const elem = document.getElementById("lastUpdated");
    if (elem) {
      elem.textContent = `Last updated: ${data.last_updated}`;
    }
  }

  // Update stats
  if (data.overall_stats) {
    document.getElementById("statRestaurants").textContent =
      data.overall_stats.total_restaurants || 0;
    document.getElementById("statOrders").textContent =
      data.overall_stats.total_orders || 0;
    document.getElementById("statRevenue").textContent =
      "Rs. " + (data.overall_stats.total_revenue || 0).toLocaleString();
    document.getElementById("statUsers").textContent =
      data.overall_stats.total_users || 0;
  }

  if (data.overall_restaurant_stats || data.today_stats) {
    const stats = data.overall_restaurant_stats || data.today_stats;
    document.getElementById("statOrdersToday").textContent =
      stats.orders_today || 0;
    document.getElementById("statActiveOrders").textContent =
      stats.active_orders || 0;
    document.getElementById("statStaff").textContent = stats.total_staff || 0;
    document.getElementById("statTables").textContent = stats.total_tables || 0;
    document.getElementById("statMenuItems").textContent =
      stats.total_menu_items || 0;
    document.getElementById("statDailyRevenue").textContent =
      "Rs. " + (stats.daily_revenue || 0).toLocaleString();
  }

  // Update charts
  if (data.daily_revenue) {
    revenueChart.data.labels = data.daily_revenue.labels || [];
    revenueChart.data.datasets[0].data = data.daily_revenue.revenue || [];
    revenueChart.update();
  }

  if (data.order_breakdown) {
    statusChart.data.datasets[0].data = [
      data.order_breakdown.pending || 0,
      data.order_breakdown.preparing || 0,
      data.order_breakdown.bargain || 0,
      data.order_breakdown.ready || 0,
      data.order_breakdown.served || 0,
      data.order_breakdown.cancelled || 0,
    ];
    statusChart.update();

    // Update order breakdown table
    document.getElementById("orderPending").textContent =
      data.order_breakdown.pending || 0;
    document.getElementById("orderPreparing").textContent =
      data.order_breakdown.preparing || 0;
    document.getElementById("orderReady").textContent =
      data.order_breakdown.ready || 0;
    document.getElementById("orderServed").textContent =
      data.order_breakdown.served || 0;
    document.getElementById("orderCancelled").textContent =
      data.order_breakdown.cancelled || 0;
  }

  if (data.hourly_dist) {
    hourlyChart.data.labels = data.hourly_dist.hours || [];
    hourlyChart.data.datasets[0].data = data.hourly_dist.orders || [];
    hourlyChart.update();
  }

  if (data.bargain_metrics) {
    bargainChart.data.datasets[0].data = [
      data.bargain_metrics.accepted || 0,
      data.bargain_metrics.rejected || 0,
      data.bargain_metrics.pending || 0,
    ];
    bargainChart.update();
  }

  // Update website data stats
  if (data.website_data_stats) {
    document.getElementById("statTotalWebsites").textContent =
      data.website_data_stats.total_websites || 0;
    document.getElementById("statActiveWebsites").textContent =
      data.website_data_stats.total_websites || 0;
    document.getElementById("statMenuOnline").textContent =
      data.website_data_stats.websites_with_menu || 0;
    document.getElementById("statReservationsOnline").textContent =
      data.website_data_stats.websites_with_reservations || 0;
  }

  // Update top items table
  if (data.top_items) {
    updateTopItemsTable(data.top_items);
  }

  // Update staff performance table
  if (data.staff_performance) {
    updateStaffTable(data.staff_performance);
  }
}

// Update Top Items Table
function updateTopItemsTable(items) {
  const tbody = document.querySelector("#topItemsTable tbody");
  if (!items || items.length === 0) {
    tbody.innerHTML =
      '<tr><td colspan="4" style="text-align: center; color: var(--text-secondary); padding: 30px;">No sales data available yet</td></tr>';
    return;
  }

  tbody.innerHTML = items
    .map(
      (item) => `
        <tr>
            <td><strong>#${item.rank}</strong></td>
            <td>${item.name}</td>
            <td>${item.quantity}</td>
            <td>Rs. ${(item.revenue || 0).toLocaleString()}</td>
        </tr>
    `,
    )
    .join("");
}

// Update Staff Table
function updateStaffTable(staff) {
  const tbody = document.querySelector("#staffTable tbody");
  if (!staff || staff.length === 0) {
    tbody.innerHTML =
      '<tr><td colspan="4" style="text-align: center; color: var(--text-secondary); padding: 30px;">No staff data available</td></tr>';
    return;
  }

  tbody.innerHTML = staff
    .map(
      (s) => `
        <tr>
            <td>${s.name}</td>
            <td><strong>${s.role}</strong></td>
            <td>${s.orders}</td>
            <td><span class="badge ${s.status === "Active" ? "active" : "inactive"}">${s.status}</span></td>
        </tr>
    `,
    )
    .join("");
}

// Loading States
function showLoading() {
  document.getElementById("loadingOverlay").classList.add("active");
}

function hideLoading() {
  document.getElementById("loadingOverlay").classList.remove("active");
}

// Update Last Updated Time
function updateLastUpdated() {
  const now = new Date();
  const timeStr = now.toLocaleTimeString();
  const elem = document.getElementById("lastUpdated");
  if (elem) {
    elem.textContent = `Last updated: ${timeStr}`;
  }
}

// Auto-refresh every 5 minutes
setInterval(() => {
  const select = document.getElementById("restaurant-select");
  if (select && select.value) {
    fetchRestaurantData(select.value);
  } else {
    refreshDashboard();
  }
}, 300000); // 5 minutes

// Filter Restaurants by Search and Status
function filterRestaurants() {
  const searchInput = document.getElementById("restaurantSearch");
  const statusFilter = document.getElementById("statusFilter");
  const restaurantCards = document.querySelectorAll(".restaurant-card");
  
  if (!searchInput || !statusFilter) return;
  
  const searchTerm = searchInput.value.toLowerCase();
  const statusTerm = statusFilter.value.toLowerCase();
  let visibleCount = 0;

  restaurantCards.forEach((card) => {
    const restaurantName = card
      .querySelector(".restaurant-card-header h3")
      .textContent.toLowerCase();
    const statusBadge = card.querySelector(".badge");
    const status = statusBadge
      ? statusBadge.textContent.toLowerCase()
      : "";

    // Check if card matches search term
    const matchesSearch = restaurantName.includes(searchTerm);

    // Check if card matches status filter
    const matchesStatus =
      !statusTerm ||
      (statusTerm === "active" && status.includes("active")) ||
      (statusTerm === "inactive" && status.includes("inactive"));

    // Show/hide card based on filters
    if (matchesSearch && matchesStatus) {
      card.style.display = "";
      visibleCount++;
    } else {
      card.style.display = "none";
    }
  });

  // Show empty message if no restaurants match
  const gridContainer = document.getElementById("restaurantsGrid");
  const existingEmptyMsg = gridContainer.querySelector(
    "[data-empty-message]"
  );

  if (visibleCount === 0) {
    if (!existingEmptyMsg) {
      const emptyMsg = document.createElement("div");
      emptyMsg.setAttribute("data-empty-message", "true");
      emptyMsg.style.cssText =
        "grid-column: 1 / -1; text-align: center; padding: 40px; background: white; border-radius: 12px;";
      emptyMsg.innerHTML =
        '<p style="color: #6b7280; font-size: 16px;">No restaurants match your search.</p>';
      gridContainer.appendChild(emptyMsg);
    }
  } else {
    if (existingEmptyMsg) {
      existingEmptyMsg.remove();
    }
  }

  // Update restaurant count
  const countBadge = document.getElementById("restaurantCount");
  if (countBadge) {
    countBadge.textContent = `(${visibleCount} restaurants)`;
  }
}
