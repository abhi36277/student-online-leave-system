// WebContent/js/dashboard.js

document.addEventListener("DOMContentLoaded", () => {
    // 1. Theme Toggle Management
    initThemeToggle();

    // 2. Real-time Date and Time Update
    initClock();

    // 3. Initialize Interactive Charts (Chart.js)
    initCharts();

    // 4. Handle notification list hover/interaction
    initNotifications();

    // 5. Initialize Mobile Sidebar Menu
    initMobileMenu();
});

// Theme Toggle logic
function initThemeToggle() {
    const toggleSwitch = document.querySelector('.theme-switch input[type="checkbox"]');
    const currentTheme = localStorage.getItem('theme') || 'light';

    // Set initial theme
    document.documentElement.setAttribute('data-theme', currentTheme);
    if (toggleSwitch) {
        toggleSwitch.checked = (currentTheme === 'dark');
        
        toggleSwitch.addEventListener('change', (e) => {
            const theme = e.target.checked ? 'dark' : 'light';
            document.documentElement.setAttribute('data-theme', theme);
            localStorage.setItem('theme', theme);
            
            // Re-render charts with new theme colors if active
            updateChartThemes(theme);
        });
    }
}

// Clock logic
function initClock() {
    const clockElement = document.getElementById('current-time');
    if (clockElement) {
        const updateTime = () => {
            const now = new Date();
            const options = { 
                weekday: 'short', 
                year: 'numeric', 
                month: 'short', 
                day: 'numeric',
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit' 
            };
            clockElement.textContent = now.toLocaleDateString('en-US', options);
        };
        updateTime();
        setInterval(updateTime, 1000);
    }
}

// Global chart references for theme updating
let trendChartInstance = null;
let distChartInstance = null;

// Chart.js configurations
function initCharts() {
    // A. Monthly Leave Trend Chart (Line Chart)
    const trendCanvas = document.getElementById('leaveTrendChart');
    if (trendCanvas && typeof Chart !== 'undefined') {
        const ctx = trendCanvas.getContext('2d');
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        
        // Define gradients
        const gradient = ctx.createLinearGradient(0, 0, 0, 200);
        gradient.addColorStop(0, isDark ? 'rgba(99, 102, 241, 0.4)' : 'rgba(59, 130, 246, 0.3)');
        gradient.addColorStop(1, 'rgba(99, 102, 241, 0)');

        const trendsAttr = trendCanvas.getAttribute('data-trends');
        let trendData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (trendsAttr) {
            trendData = trendsAttr.split(',').map(Number);
        }

        trendChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Leaves Applied',
                    data: trendData,
                    borderColor: isDark ? '#6366f1' : '#3b82f6',
                    borderWidth: 3,
                    backgroundColor: gradient,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: isDark ? '#a855f7' : '#8b5cf6',
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        grid: { color: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)' },
                        ticks: { color: isDark ? '#a1a1aa' : '#64748b' }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: isDark ? '#a1a1aa' : '#64748b' }
                    }
                }
            }
        });
    }

    // B. Leave Distribution Chart (Doughnut Chart)
    const distCanvas = document.getElementById('leaveDistributionChart');
    if (distCanvas && typeof Chart !== 'undefined') {
        const ctx = distCanvas.getContext('2d');
        
        // Parse DB data from data attributes
        const approved = parseInt(distCanvas.getAttribute('data-approved') || '0');
        const pending = parseInt(distCanvas.getAttribute('data-pending') || '0');
        const rejected = parseInt(distCanvas.getAttribute('data-rejected') || '0');
        
        const hasData = (approved + pending + rejected) > 0;
        const chartData = hasData ? [approved, pending, rejected] : [1, 1, 1];
        const chartLabels = hasData ? ['Approved', 'Pending', 'Rejected'] : ['No Data', 'No Data', 'No Data'];
        const chartColors = hasData ? ['#10b981', '#f59e0b', '#ef4444'] : ['#e2e8f0', '#e2e8f0', '#e2e8f0'];

        distChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: chartLabels,
                datasets: [{
                    data: chartData,
                    backgroundColor: chartColors,
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: document.documentElement.getAttribute('data-theme') === 'dark' ? '#a1a1aa' : '#64748b',
                            boxWidth: 12,
                            font: { size: 11 }
                        }
                    }
                },
                cutout: '70%'
            }
        });
    }
}

// Update chart theme colors dynamically on toggle
function updateChartThemes(theme) {
    const isDark = (theme === 'dark');
    const textColor = isDark ? '#a1a1aa' : '#64748b';
    const gridColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)';
    const primaryColor = isDark ? '#6366f1' : '#3b82f6';

    if (trendChartInstance) {
        trendChartInstance.options.scales.y.grid.color = gridColor;
        trendChartInstance.options.scales.y.ticks.color = textColor;
        trendChartInstance.options.scales.x.ticks.color = textColor;
        trendChartInstance.data.datasets[0].borderColor = primaryColor;
        
        // Rebuild gradient
        const ctx = document.getElementById('leaveTrendChart').getContext('2d');
        const gradient = ctx.createLinearGradient(0, 0, 0, 200);
        gradient.addColorStop(0, isDark ? 'rgba(99, 102, 241, 0.4)' : 'rgba(59, 130, 246, 0.3)');
        gradient.addColorStop(1, 'rgba(99, 102, 241, 0)');
        trendChartInstance.data.datasets[0].backgroundColor = gradient;
        
        trendChartInstance.update();
    }

    if (distChartInstance) {
        distChartInstance.options.plugins.legend.labels.color = textColor;
        distChartInstance.update();
    }
}

// Notification highlights
function initNotifications() {
    const notifications = document.querySelectorAll('.notification-item');
    notifications.forEach(item => {
        item.addEventListener('mouseenter', () => {
            item.style.backgroundColor = 'var(--primary-glow)';
            item.style.borderRadius = '6px';
            item.style.paddingLeft = '6px';
        });
        item.addEventListener('mouseleave', () => {
            item.style.backgroundColor = 'transparent';
            item.style.paddingLeft = '0';
        });
    });
}

// Toast notification helper
function showToast(message, type = 'success') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    // Choose icon
    let icon = '🔔';
    if (type === 'success') icon = '✅';
    else if (type === 'danger') icon = '❌';
    else if (type === 'warning') icon = '⚠️';

    toast.innerHTML = `
        <span>${icon}</span>
        <div class="noti-text" style="font-weight: 500;">${message}</div>
    `;

    container.appendChild(toast);

    // Fade out and remove
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease forwards';
        toast.addEventListener('animationend', () => {
            toast.remove();
        });
    }, 4000);
}

// Inject keyframes for slideOut dynamically if not present
if (!document.getElementById('toast-keyframes')) {
    const style = document.createElement('style');
    style.id = 'toast-keyframes';
    style.innerHTML = `
        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(120%); opacity: 0; }
        }
    `;
    document.head.appendChild(style);
}

// Modal Toggle Helpers
function openModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add('show');
}

function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('show');
}

// Mobile sidebar logic
function initMobileMenu() {
    const toggleBtn = document.getElementById('mobile-menu-toggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (toggleBtn && sidebar) {
        // Create overlay element dynamically if not present
        let overlay = document.querySelector('.sidebar-overlay');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.className = 'sidebar-overlay';
            document.body.appendChild(overlay);
        }
        
        toggleBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('show');
            overlay.classList.toggle('show');
        });
        
        overlay.addEventListener('click', () => {
            sidebar.classList.remove('show');
            overlay.classList.remove('show');
        });
        
        // Close sidebar on menu item click (if navigating on same page/anchor)
        const menuItems = sidebar.querySelectorAll('.menu-item');
        menuItems.forEach(item => {
            item.addEventListener('click', () => {
                sidebar.classList.remove('show');
                overlay.classList.remove('show');
            });
        });
    }
}
