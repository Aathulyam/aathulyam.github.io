// Athulyam Group online
console.log("Athulyam Group online");

// Athulyam Group online.
console.log('Athulyam Group online.');

// ===== Scroll Fade-In Animation with Fallback =====
document.addEventListener('DOMContentLoaded', () => {
  const faders = document.querySelectorAll('.fade-in');

  // If nothing to animate, bail quietly
  if (!faders.length) return;

  // Helper to reveal elements
  const reveal = el => el.classList.add('visible');

  // Fallback for older browsers or if IntersectionObserver fails
  const fallback = () => {
    const trigger = window.innerHeight * 0.85; // reveal when 85% in view
    faders.forEach(el => {
      const rect = el.getBoundingClientRect();
      if (rect.top < trigger) reveal(el);
    });
  };

  // Try IntersectionObserver first
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver((entries, obs) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        reveal(entry.target);
        obs.unobserve(entry.target);
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -30px 0px' });

    faders.forEach(el => io.observe(el));
  } else {
    // Fallback path
    fallback();
    window.addEventListener('scroll', fallback, { passive: true });
  }

  // Ensure elements already in view on load become visible (e.g., creed near top)
  setTimeout(() => {
    faders.forEach(el => {
      const rect = el.getBoundingClientRect();
      if (rect.top < window.innerHeight * 0.85) reveal(el);
    });
  }, 50);
});
