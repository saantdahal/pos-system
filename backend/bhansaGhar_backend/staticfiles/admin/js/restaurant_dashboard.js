// Custom JS for Restaurant Dashboard
// Extracted from restaurant_dashboard.html

// Color palette
const colors = {
  primary: "#6366f1",
  secondary: "#10b981",
  danger: "#ef4444",
  warning: "#f59e0b",
  info: "#3b82f6",
};

// Get chart data from JSON
document.addEventListener("DOMContentLoaded", function () {
  const chartDataEl = document.getElementById("chart-data");
  const chartData = chartDataEl ? JSON.parse(chartDataEl.textContent) : {};

  // Initialize Charts
  function initCharts() {
    // Revenue Chart
    const revenueCtx = document.getElementById("revenueChart").getContext("2d");
    new Chart(revenueCtx, {
      type: "line",
      data: {
        labels: chartData.revenueLabels || [],
        datasets: [
          {
            label: "Revenue (Rs.)",
            data: chartData.revenueData || [],
            borderColor: colors.primary,
            backgroundColor: "rgba(99, 102, 241, 0.1)",
            fill: true,
            tension: 0.4,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: { ticks: { maxTicksLimit: 10 } },
          y: { beginAtZero: true },
        },
      },
    });

    // Status Chart
    const statusCtx = document.getElementById("statusChart").getContext("2d");
    new Chart(statusCtx, {
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
              "#8b5cf6",
              colors.secondary,
              colors.primary,
              colors.danger,
            ],
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "right" } },
      },
    });

    // Hourly Chart
    const hourlyCtx = document.getElementById("hourlyChart").getContext("2d");
    new Chart(hourlyCtx, {
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
        scales: { x: { ticks: { maxTicksLimit: 12 } } },
      },
    });

    // Bargain Chart
    const bargainCtx = document.getElementById("bargainChart").getContext("2d");
    new Chart(bargainCtx, {
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

  // Go back to overview
  window.goBackToOverview = function () {
    window.location.href = "/admin/";
  };

  // Modal functions
  window.openEditModal = function () {
    document.getElementById("editModal").style.display = "block";
    document.body.style.overflow = "hidden";
  };

  window.closeEditModal = function () {
    document.getElementById("editModal").style.display = "none";
    document.body.style.overflow = "auto";
  };

  // Close modal when clicking outside
  window.onclick = function (event) {
    const modal = document.getElementById("editModal");
    if (event.target == modal) {
      window.closeEditModal();
    }
  };

  // Handle form submission
  const editForm = document.getElementById("editRestaurantForm");
  if (editForm) {
    editForm.addEventListener("submit", function (e) {
      e.preventDefault();

      const formData = new FormData(this);
      const restaurantId = "{{ restaurant_data.id }}";

      // Add restaurant ID to form data
      formData.append("restaurant_id", restaurantId);

      // Show loading
      const submitBtn = this.querySelector('button[type="submit"]');
      const originalText = submitBtn.textContent;
      submitBtn.textContent = "Saving...";
      submitBtn.disabled = true;

      fetch(`/admin/restaurant/update/`, {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRFToken": document.querySelector("[name=csrfmiddlewaretoken]")
            .value,
        },
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.success) {
            // Update the UI with new data
            document.getElementById("restaurantName").textContent =
              formData.get("name");

            // Close modal
            window.closeEditModal();

            // Show success message
            showNotification(
              "Restaurant details updated successfully!",
              "success",
            );

            // Reload page to reflect changes
            setTimeout(() => {
              window.location.reload();
            }, 1500);
          } else {
            showNotification(
              "Error updating restaurant details: " +
                (data.error || "Unknown error"),
              "error",
            );
          }
        })
        .catch((error) => {
          console.error("Error:", error);
          showNotification("Error updating restaurant details", "error");
        })
        .finally(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        });
    });
  }

  // Notification function
  window.showNotification = function (message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll(".notification");
    existingNotifications.forEach((notification) => notification.remove());

    // Create notification element
    const notification = document.createElement("div");
    notification.className = `notification ${type}`;
    notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            z-index: 1001;
            animation: slideInRight 0.3s ease-out;
            max-width: 400px;
        `;

    if (type === "success") {
      notification.style.backgroundColor = "var(--accent-color)";
    } else {
      notification.style.backgroundColor = "var(--danger-color)";
    }

    notification.textContent = message;
    document.body.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
      notification.style.animation = "slideOutRight 0.3s ease-in";
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }, 5000);
  };

  // Initialize
  initCharts();
});
