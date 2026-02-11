        (function () {
            // --- Navbar scroll effect ---
            const navbar = document.getElementById('navbar');
            window.addEventListener('scroll', () => {
                navbar.classList.toggle('scrolled', window.scrollY > 60);
            });

            // --- Scroll reveal ---
            const revealEls = document.querySelectorAll('.reveal');
            const revealObserver = new IntersectionObserver((entries) => {
                entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); } });
            }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
            revealEls.forEach(el => revealObserver.observe(el));

            // --- Category filtering ---
            document.querySelectorAll('.cat-pill').forEach(pill => {
                pill.addEventListener('click', function () {
                    document.querySelectorAll('.cat-pill').forEach(p => p.classList.remove('active'));
                    this.classList.add('active');
                    const cat = this.dataset.category;
                    document.querySelectorAll('.menu-item').forEach(item => {
                        const show = cat === 'all' || item.dataset.category === cat;
                        item.style.transition = 'opacity 0.3s, transform 0.3s';
                        if (show) {
                            item.style.opacity = '1';
                            item.style.transform = 'translateY(0)';
                            item.style.display = 'flex';
                        } else {
                            item.style.opacity = '0';
                            item.style.transform = 'translateY(12px)';
                            setTimeout(() => { item.style.display = 'none'; }, 300);
                        }
                    });
                });
            });

            // --- Toast notification ---
            let toastTimer;
            window.showToast = function () {
                const toast = document.getElementById('toast');
                toast.classList.add('show');
                clearTimeout(toastTimer);
                toastTimer = setTimeout(() => toast.classList.remove('show'), 2800);
            };

            // --- Share ---
            window.shareRestaurant = function () {
                if (navigator.share) {
                    navigator.share({
                        title: '{{ restaurant.name }}',
                        text: '{{ restaurant.description }}',
                        url: window.location.href
                    }).catch(() => { });
                } else {
                    navigator.clipboard?.writeText(window.location.href).then(() => showToast());
                }
            };

            // --- Go back ---
            window.goBack = function () { window.history.back(); };

            // --- Initialize map ---
            if (document.getElementById('map')) {
                var map = L.map('map').setView([{{ restaurant.latitude|default:"27.7172" }}, {{ restaurant.longitude|default:"85.3240" }}], 15);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap contributors'
                }).addTo(map);
                L.marker([{{ restaurant.latitude|default:"27.7172" }}, {{ restaurant.longitude|default:"85.3240" }}]).addTo(map)
                    .bindPopup('{{ restaurant.name }}<br>{{ restaurant.address }}')
                    .openPopup();
            }
        })();
