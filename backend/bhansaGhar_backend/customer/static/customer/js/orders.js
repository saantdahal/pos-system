let tableId = '{{ table.id|default:"" }}';

function goBack() {
  window.location.href = "/menu/" + (tableId || "");
}

function showMenuPage() {
  window.location.href = "/menu/" + (tableId || "");
}

function openCart() {
  // For now, just show menu (cart functionality would be implemented)
  showMenuPage();
}

function leaveTable() {
  if (confirm("Are you sure you want to leave this table?")) {
    window.location.href = "/leave/";
  }
}
