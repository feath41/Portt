// Copy Email Handling
(function() {
  const copyBtn = document.getElementById('copy-email-btn');
  const copyLabel = document.getElementById('copy-email-label');
  if (copyBtn && copyLabel) {
    copyBtn.addEventListener('click', async () => {
      const email = 'dipoarya25@gmail.com';
      try {
        if (navigator.clipboard) {
          await navigator.clipboard.writeText(email);
        }
        const original = copyLabel.textContent;
        copyLabel.textContent = '[COPIED TO CLIPBOARD]';
        setTimeout(() => {
          copyLabel.textContent = original;
        }, 2000);
      } catch (e) {
        window.location.href = 'mailto:' + email;
      }
    });
  }

  // Interactive Terminal Filter Tabs
  const filterTabs = document.querySelectorAll('.filter-tab-btn');
  const shieldCard = document.getElementById('project-shield-card');
  const emptyState = document.getElementById('project-empty-state');
  const emptyQuery = document.getElementById('terminal-empty-query');
  const countDisplay = document.getElementById('artifact-count-display');

  if (filterTabs.length > 0) {
    filterTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const cat = tab.getAttribute('data-cat');

        // Reset all tabs to inactive state
        filterTabs.forEach(t => {
          t.className = 'filter-tab-btn flex items-center gap-2 px-3 py-1.5 rounded border border-transparent text-zinc-400 hover:text-brand-white hover:border-brand-border hover:bg-brand-darker font-mono text-xs tracking-wider transition-all';
          const ind = t.querySelector('.tab-indicator');
          if (ind) ind.classList.add('opacity-0');
        });

        // Set active styling to clicked tab
        tab.className = 'filter-tab-btn flex items-center gap-2 px-3 py-1.5 rounded border border-brand-accent text-brand-accent bg-brand-accentMuted font-mono text-xs tracking-wider transition-all shadow-[0_0_12px_rgba(34,197,94,0.15)]';
        const activeIndicator = tab.querySelector('.tab-indicator');
        if (activeIndicator) activeIndicator.classList.remove('opacity-0');

        // Filter logic
        if (cat === 'all' || cat === 'sec') {
          if (shieldCard) shieldCard.classList.remove('hidden');
          if (emptyState) emptyState.classList.add('hidden');
          if (countDisplay) {
            countDisplay.textContent = '[FEATURED ARTIFACT: 01 OF 01]';
          }
        } else {
          if (shieldCard) shieldCard.classList.add('hidden');
          if (emptyState) emptyState.classList.remove('hidden');
          if (countDisplay) {
            countDisplay.textContent = '[STAGED ARTIFACTS: 00 OF 00]';
          }
          if (emptyQuery) {
            const queryName = cat === 'uiux' ? 'ui_ux_systems' : 'audits_research';
            emptyQuery.textContent = 'sec-filter --category=' + queryName + ' --depth=strict';
          }
        }
      });
    });
  }
})();

// Smooth Scroll for Anchor Links
(function() {
  document.addEventListener('DOMContentLoaded', function() {
    const scrollTriggers = document.querySelectorAll('.scroll-trigger');
    scrollTriggers.forEach(function(link) {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        const targetSelector = this.getAttribute('data-target') || this.getAttribute('href');
        const target = document.querySelector(targetSelector);
        if (target) {
          const startPosition = window.pageYOffset;
          const targetPosition = target.getBoundingClientRect().top + startPosition;
          const distance = targetPosition - startPosition;
          const duration = 900;

          function easeInOutCubic(t, b, c, d) {
            t /= d / 2;
            if (t < 1) return c / 2 * t * t * t + b;
            t -= 2;
            return -c / 2 * (t * t * t - 2) + b;
          }

          const startTime = performance.now();
          function step(currentTime) {
            const elapsed = currentTime - startTime;
            const run = easeInOutCubic(elapsed, startPosition, distance, duration);
            window.scrollTo(0, run);
            if (elapsed < duration) requestAnimationFrame(step);
          }
          requestAnimationFrame(step);
        }
      });
    });
  });
})();
