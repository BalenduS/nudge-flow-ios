const users = [
  { name: "Balendu Singh", email: "balendu@example.com", plan: "Free Plan", signup: "Jan 2026", active: "4 min ago", widgetLogs: 38, status: "ok", support: "Reason required" },
  { name: "Aarav Mehta", email: "aarav@example.com", plan: "Premium Trial", signup: "Feb 2026", active: "22 min ago", widgetLogs: 114, status: "ok", support: "Reason required" },
  { name: "Priya Rao", email: "priya@example.com", plan: "Free Plan", signup: "Mar 2026", active: "1 hour ago", widgetLogs: 17, status: "warn", support: "Export pending" },
  { name: "Maya Shah", email: "maya@example.com", plan: "Premium", signup: "Apr 2026", active: "Yesterday", widgetLogs: 202, status: "locked", support: "Locked" },
  { name: "Dev Nair", email: "dev@example.com", plan: "Free Plan", signup: "May 2026", active: "2 days ago", widgetLogs: 9, status: "ok", support: "Reason required" }
];

const privacyRequests = [
  { title: "CSV export requested", detail: "Priya Rao · due today" },
  { title: "Account deletion review", detail: "Maya Shah · legal hold check" },
  { title: "Consent record lookup", detail: "Aarav Mehta · support ticket #184" }
];

const articles = [
  { title: "Your First 16:8 Week", category: "Fasting 101", status: "Published" },
  { title: "What Counts as Breaking a Fast?", category: "Fasting 101", status: "Draft" },
  { title: "Electrolytes Without Overthinking", category: "Hydration", status: "Published" },
  { title: "Reading Your Consumption Patterns", category: "Mindset", status: "Scheduled" },
  { title: "Autophagy in Plain English", category: "Science", status: "Featured" },
  { title: "Coffee, Tea, and Fasting", category: "Hydration", status: "Published" }
];

const auditRows = [
  ["16:12", "Balendu", "Opened user detail", "Priya Rao", "Export request review"],
  ["15:48", "Support Admin", "Updated article", "Electrolytes Without Overthinking", "Typo fix"],
  ["14:20", "System", "Export generated", "Priya Rao", "User request"],
  ["12:04", "Balendu", "Changed role", "Content Editor", "Access review"]
];

const chartValues = [74, 91, 66, 88, 93, 52, 79];
const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

function statusClass(status) {
  return status === "locked" ? "locked" : status === "warn" ? "warn" : "ok";
}

function renderUsers(targetId, rows = users) {
  const target = document.getElementById(targetId);
  target.innerHTML = rows.map(user => `
    <tr>
      <td class="user-cell">${user.name}</td>
      ${targetId === "usersTable" ? `<td>${user.email}</td>` : ""}
      <td>${user.plan}</td>
      ${targetId === "usersTable" ? `<td>${user.signup}</td>` : ""}
      <td>${user.active}</td>
      <td>${targetId === "usersTable" ? user.support : user.widgetLogs}</td>
      <td><span class="status ${statusClass(user.status)}">${user.status}</span></td>
    </tr>
  `).join("");
}

function renderRequests(targetId) {
  document.getElementById(targetId).innerHTML = privacyRequests.map(request => `
    <div class="request">
      <strong>${request.title}</strong>
      <span>${request.detail}</span>
    </div>
  `).join("");
}

function renderArticles() {
  document.getElementById("articleGrid").innerHTML = articles.map(article => `
    <article class="article-card">
      <span class="tag">${article.status}</span>
      <strong>${article.title}</strong>
      <p>${article.category} · behavior-trigger ready</p>
    </article>
  `).join("");
}

function renderAudit() {
  document.getElementById("auditTable").innerHTML = auditRows.map(row => `
    <tr>${row.map(cell => `<td>${cell}</td>`).join("")}</tr>
  `).join("");
}

function renderChart() {
  document.getElementById("fastingChart").innerHTML = chartValues.map((value, index) => `
    <div class="bar" style="height:${value}%"><span>${days[index]}</span></div>
  `).join("");
}

function switchSection(sectionId) {
  document.querySelectorAll(".section").forEach(section => section.classList.toggle("active", section.id === sectionId));
  document.querySelectorAll(".nav-item").forEach(item => item.classList.toggle("active", item.dataset.section === sectionId));
  document.getElementById("sectionTitle").textContent = document.querySelector(`[data-section="${sectionId}"]`)?.textContent || "Overview";
}

function applySearch(query) {
  const normalized = query.trim().toLowerCase();
  const filtered = normalized
    ? users.filter(user => [user.name, user.email, user.plan, user.status].some(value => value.toLowerCase().includes(normalized)))
    : users;
  renderUsers("overviewUsers", filtered);
  renderUsers("usersTable", filtered);
}

document.querySelectorAll(".nav-item").forEach(button => {
  button.addEventListener("click", () => switchSection(button.dataset.section));
});

document.querySelectorAll("[data-jump]").forEach(button => {
  button.addEventListener("click", () => switchSection(button.dataset.jump));
});

document.getElementById("searchInput").addEventListener("input", event => applySearch(event.target.value));

renderChart();
renderUsers("overviewUsers");
renderUsers("usersTable");
renderRequests("privacyPreview");
renderRequests("privacyRequests");
renderArticles();
renderAudit();
