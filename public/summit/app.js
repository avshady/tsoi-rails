import initialData from './cms-data.js?v=6';

// Setup global store for CMS editing
if (!window.currentCmsData) {
  window.currentCmsData = JSON.parse(JSON.stringify(initialData));
}

// Function to render the entire page from CMS data
export function renderPage(data) {
  // --- 1. HERO SECTION ---
  document.getElementById('hero-headline').innerHTML = formatHeading(data.hero.headline);
  document.getElementById('hero-subheadline').textContent = data.hero.subheadline;
  document.getElementById('hero-date').textContent = data.hero.dates;
  document.getElementById('hero-location-text').textContent = data.hero.location;
  
  const ctaPrimary = document.getElementById('hero-cta-primary');
  ctaPrimary.textContent = data.hero.ctaPrimary.text;
  ctaPrimary.setAttribute('href', data.hero.ctaPrimary.action);
  
  const ctaSecondary = document.getElementById('hero-cta-secondary');
  ctaSecondary.textContent = data.hero.ctaSecondary.text;
  ctaSecondary.setAttribute('href', data.hero.ctaSecondary.action);

  // --- 2. INTRODUCTION ---
  document.getElementById('intro-title').innerHTML = formatHeading(data.intro.title);
  document.getElementById('intro-p1').textContent = data.intro.paragraph1;
  document.getElementById('intro-p2').textContent = data.intro.paragraph2;

  // --- 3. WHY ATTEND ---
  const whyGrid = document.getElementById('why-grid');
  whyGrid.innerHTML = data.whyAttend.map((item, index) => `
    <div class="why-card">
      <div class="why-card-icon">${index + 1}</div>
      <h3 class="why-card-title">${item.title}</h3>
      <p class="why-card-desc">${item.description}</p>
    </div>
  `).join('');

  // --- 4. WHO SHOULD ATTEND ---
  const whoGrid = document.getElementById('who-grid');
  whoGrid.innerHTML = data.whoShouldAttend.map(role => `
    <div class="who-badge">${role}</div>
  `).join('');

  // --- 5. THE EXPERIENCE (TIMELINE) ---
  document.getElementById('experience-title').innerHTML = formatHeading(data.experience.title);
  const experienceTimeline = document.getElementById('experience-timeline');
  experienceTimeline.innerHTML = data.experience.days.map(dayInfo => `
    <div class="timeline-item color-${dayInfo.color}">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <div class="timeline-day">${dayInfo.day}</div>
        <h3 class="timeline-theme">${dayInfo.theme}</h3>
        <p class="timeline-desc">${dayInfo.description}</p>
      </div>
    </div>
  `).join('');

  // --- 6. THEMES ---
  const themesGrid = document.getElementById('themes-grid');
  themesGrid.innerHTML = data.themes.map(theme => `
    <div class="theme-card">
      <div class="theme-bullet"></div>
      <span class="theme-name">${theme}</span>
    </div>
  `).join('');

  // --- 7. SPEAKERS SECTION ---
  // Grid is server-rendered in ERB; only update text elements
  document.getElementById('speakers-title').innerHTML = formatHeading(data.speakers.title);
  document.getElementById('speakers-soon-text').textContent = data.speakers.subtitle;

  // --- 8. SESSIONS ---
  const sessionsGrid = document.getElementById('sessions-grid');
  sessionsGrid.innerHTML = data.sessions.map(sess => `
    <div class="session-card">
      <div class="session-icon">${sess.icon}</div>
      <h3 class="session-title">${sess.title}</h3>
      <p class="session-desc">${sess.description}</p>
    </div>
  `).join('');

  // --- 9. FEATURED INSTITUTIONS (LOGO WALL) ---
  const logoTrack = document.getElementById('logo-track');
  // Duplicate array twice to ensure smooth infinite loop animation width
  const logoItemsHtml = [...data.institutions, ...data.institutions, ...data.institutions].map(inst => `
    <div class="logo-item">
      <div class="logo-item-icon"></div>
      <span>${inst.name}</span>
      <span style="font-size: 0.65rem; color: var(--text-dimmed); text-transform: uppercase;">(${inst.type})</span>
    </div>
  `).join('');
  logoTrack.innerHTML = logoItemsHtml;

  // --- 10. NETWORKING ---
  const netGrid = document.getElementById('net-grid');
  netGrid.innerHTML = data.networking.map(item => `
    <div class="feature-card">
      <h3 class="feature-card-title">${item.title}</h3>
      <p class="feature-card-desc">${item.description}</p>
    </div>
  `).join('');

  // --- 11. INNOVATION SHOWCASE ---
  const showcaseGrid = document.getElementById('showcase-grid');
  showcaseGrid.innerHTML = data.innovationShowcase.map(item => `
    <div class="feature-card">
      <h3 class="feature-card-title" style="color: var(--color-lime);">${item.title}</h3>
      <p class="feature-card-desc">${item.desc}</p>
    </div>
  `).join('');

  // --- 12. VENUE ---
  document.getElementById('venue-name').textContent = data.venue.name;
  document.getElementById('venue-city').textContent = data.venue.city;
  document.getElementById('venue-parking').textContent = data.venue.parking;
  document.getElementById('venue-hotels').textContent = data.venue.hotels;
  document.getElementById('venue-travel').textContent = data.venue.travel;
  document.getElementById('venue-coords').textContent = data.venue.mapPlaceholder;

  // --- 13. SCHEDULE (AGENDA) ---
  renderSchedule(data.schedule);

  // --- 14. REGISTRATION TICKETS ---
  const regGrid = document.getElementById('reg-grid');
  regGrid.innerHTML = data.registration.map(pass => `
    <div class="reg-card ${pass.popular ? 'is-popular' : ''}">
      ${pass.popular ? `<div class="reg-popular-badge">Most Popular</div>` : ''}
      <h3 class="reg-name">${pass.name}</h3>
      <div class="reg-price">${pass.price}</div>
      <p class="reg-subtext">${pass.subtext}</p>
      <ul class="reg-features">
        ${pass.features.map(f => `<li class="reg-feature-item">${f}</li>`).join('')}
      </ul>
      <button class="btn btn-secondary reg-btn" data-pass-id="${pass.id}" data-pass-name="${pass.name}">
        ${pass.cta}
      </button>
    </div>
  `).join('');

  // Attach event listeners to ticket CTAs
  document.querySelectorAll('.reg-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const passId = btn.getAttribute('data-pass-id');
      const passName = btn.getAttribute('data-pass-name');
      openRegistrationModal(passId, passName);
    });
  });

  // --- 15. PARTNERS & SPONSORS ---
  document.getElementById('partners-title').innerHTML = formatHeading(data.partners.title);
  const partnersContainer = document.getElementById('partners-container');
  partnersContainer.innerHTML = data.partners.tiers.map(tier => `
    <div class="partner-tier-block">
      <h3 class="partner-tier-name">${tier.name}</h3>
      <div class="partner-logo-grid">
        ${tier.partners.map(p => `
          <div class="partner-logo">
            <span>${p}</span>
          </div>
        `).join('')}
      </div>
    </div>
  `).join('');

  // --- 16. TESTIMONIALS (CAROUSEL) ---
  const testimonialsTrack = document.getElementById('testimonials-track');
  testimonialsTrack.innerHTML = data.testimonials.map(t => `
    <div class="testimonial-card color-${t.color}">
      <p class="testimonial-quote">“${t.quote}”</p>
      <div class="testimonial-author-info">
        <div class="testimonial-author-avatar">${t.author.charAt(0)}</div>
        <div class="testimonial-author-details">
          <span class="testimonial-author-name">${t.author}</span>
          <span class="testimonial-author-role">${t.role}, ${t.institution}</span>
        </div>
      </div>
    </div>
  `).join('');

  // Render dots for testimonial carousel
  const dotsContainer = document.getElementById('carousel-dots');
  dotsContainer.innerHTML = data.testimonials.map((_, idx) => `
    <button class="carousel-dot ${idx === 0 ? 'is-active' : ''}" data-index="${idx}" aria-label="Go to testimonial slide ${idx + 1}"></button>
  `).join('');

  setupTestimonialCarousel();

  // --- 17. FREQUENTLY ASKED QUESTIONS ---
  const faqsContainer = document.getElementById('faqs-container');
  faqsContainer.innerHTML = data.faqs.map(faq => `
    <div class="faq-item">
      <button class="faq-trigger">
        <span>${faq.question}</span>
        <span class="faq-icon-cross">+</span>
      </button>
      <div class="faq-panel">
        <div class="faq-content">
          <p class="faq-answer">${faq.answer}</p>
        </div>
      </div>
    </div>
  `).join('');

  setupFaqAccordion();

  // --- 18. CALL TO ACTION BANNER ---
  document.getElementById('cta-banner-title').innerHTML = formatHeading(data.ctaSection.title);
  document.getElementById('cta-banner-sub').textContent = data.ctaSection.subheadline;
  document.getElementById('cta-banner-dates').textContent = data.ctaSection.dates;
  
  const ctaBannerPrimary = document.getElementById('cta-banner-primary');
  ctaBannerPrimary.textContent = data.ctaSection.ctaPrimary.text;
  ctaBannerPrimary.setAttribute('href', data.ctaSection.ctaPrimary.action);
  
  const ctaBannerSecondary = document.getElementById('cta-banner-secondary');
  ctaBannerSecondary.textContent = data.ctaSection.ctaSecondary.text;
  ctaBannerSecondary.setAttribute('href', data.ctaSection.ctaSecondary.action);

  // --- 19. FOOTER ---
  document.getElementById('footer-about-text').textContent = data.footer.about;
  document.getElementById('footer-email').textContent = data.footer.contact.email;
  document.getElementById('footer-phone').textContent = data.footer.contact.phone;
  document.getElementById('footer-address').textContent = data.footer.contact.address;

  const footerLinks = document.getElementById('footer-links');
  footerLinks.innerHTML = data.footer.links.map(link => `
    <li><a href="${link.url}" class="footer-bottom-link">${link.text}</a></li>
  `).join('');

  const footerSocials = document.getElementById('footer-socials');
  footerSocials.innerHTML = data.footer.socials.map(social => `
    <a href="${social.url}" target="_blank" rel="noopener noreferrer" class="footer-social-link" aria-label="${social.name}">
      <!-- Dynamic mini SVG or text representing logo -->
      <span style="font-size:0.75rem; font-weight:800;">${social.name.charAt(0)}</span>
    </a>
  `).join('');
}

/* ----------------------------------------------------
   UTILITY AND INTERACTION FUNCTIONS
   ---------------------------------------------------- */

// Formats headings to insert Instrument Serif italics on key words (like Future, Schools, etc.)
function formatHeading(text) {
  const emphasisWords = ['Future', 'Schools', 'School', 'Visionaries', 'Leaders', 'Endless', 'Attend', 'Shaping'];
  let formatted = text;
  emphasisWords.forEach(word => {
    const regex = new RegExp(`\\b${word}\\b`, 'g');
    formatted = formatted.replace(regex, `<span class="serif-italic">${word}</span>`);
  });
  return formatted;
}

// Render dynamic schedule list
function renderSchedule(scheduleData, selectedDay = 'Day1') {
  const scheduleList = document.getElementById('schedule-list');
  const daySchedule = scheduleData[selectedDay];

  if (!daySchedule || daySchedule.length === 0) {
    scheduleList.innerHTML = `<p style="text-align:center; padding: 2rem;">No sessions scheduled for this day yet.</p>`;
    return;
  }

  scheduleList.innerHTML = daySchedule.map(session => `
    <div class="schedule-item">
      <div class="schedule-time">${session.time}</div>
      <div class="schedule-info">
        <h3 class="schedule-session-title">${session.title}</h3>
        <p class="schedule-speaker">${session.speaker ? `By ${session.speaker}` : ''}</p>
      </div>
      <div class="schedule-location">${session.location}</div>
    </div>
  `).join('');
}

// Setup schedule tabs filter
function setupScheduleFilters() {
  const tabs = document.querySelectorAll('.schedule-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('is-active'));
      tab.classList.add('is-active');
      const day = tab.getAttribute('data-day');
      renderSchedule(window.currentCmsData.schedule, day);
    });
  });
}

// Testimonials Carousel behavior (Scroll Snap matching Web Guidance)
function setupTestimonialCarousel() {
  const track = document.getElementById('testimonials-track');
  const prevBtn = document.getElementById('carousel-prev');
  const nextBtn = document.getElementById('carousel-next');
  const dots = document.querySelectorAll('.carousel-dot');

  if (!track || !prevBtn || !nextBtn) return;

  const updateActiveDot = (activeIndex) => {
    dots.forEach((dot, idx) => {
      if (idx === activeIndex) {
        dot.classList.add('is-active');
      } else {
        dot.classList.remove('is-active');
      }
    });
  };

  // Scroll to index
  const scrollToSlide = (index) => {
    const cardWidth = track.firstElementChild.getBoundingClientRect().width;
    const gap = 24; // 1.5rem
    track.scrollTo({
      left: index * (cardWidth + gap),
      behavior: 'smooth'
    });
    updateActiveDot(index);
  };

  // Dot clicks
  dots.forEach(dot => {
    dot.addEventListener('click', () => {
      const idx = parseInt(dot.getAttribute('data-index'), 10);
      scrollToSlide(idx);
    });
  });

  // Next / Prev triggers
  nextBtn.addEventListener('click', () => {
    const cardWidth = track.firstElementChild.getBoundingClientRect().width;
    const gap = 24;
    let nextIndex = Math.round(track.scrollLeft / (cardWidth + gap)) + 1;
    if (nextIndex >= dots.length) nextIndex = 0; // Wrap around
    scrollToSlide(nextIndex);
  });

  prevBtn.addEventListener('click', () => {
    const cardWidth = track.firstElementChild.getBoundingClientRect().width;
    const gap = 24;
    let prevIndex = Math.round(track.scrollLeft / (cardWidth + gap)) - 1;
    if (prevIndex < 0) prevIndex = dots.length - 1; // Wrap around
    scrollToSlide(prevIndex);
  });

  // Native scroll snapping detection
  let scrollTimeout;
  track.addEventListener('scroll', () => {
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
      const cardWidth = track.firstElementChild.getBoundingClientRect().width;
      const gap = 24;
      const activeIndex = Math.round(track.scrollLeft / (cardWidth + gap));
      updateActiveDot(activeIndex);
    }, 150);
  });
}

// FAQs accordion triggers
function setupFaqAccordion() {
  const items = document.querySelectorAll('.faq-item');
  items.forEach(item => {
    const trigger = item.querySelector('.faq-trigger');
    trigger.addEventListener('click', () => {
      const isActive = item.classList.contains('is-active');
      
      // Close other accordions
      items.forEach(otherItem => {
        otherItem.classList.remove('is-active');
      });

      // Toggle current
      if (!isActive) {
        item.classList.add('is-active');
      }
    });
  });
}

// Native Dialog registration modal triggers
const regDialog = document.getElementById('registration-dialog');
const closeBtn = document.getElementById('modal-close-btn');
const regForm = document.getElementById('modal-form');

function openRegistrationModal(passId, passName) {
  document.getElementById('form-pass-id').value = passId;
  document.getElementById('form-pass-name').value = passName;
  regDialog.showModal();
}

if (closeBtn) {
  closeBtn.addEventListener('click', () => {
    regDialog.close();
  });
}

// Handle dialog background click to dismiss dialog (light dismiss fallback)
if (regDialog) {
  regDialog.addEventListener('click', (event) => {
    const rect = regDialog.getBoundingClientRect();
    const isInDialog = (
      rect.top <= event.clientY &&
      event.clientY <= rect.top + rect.height &&
      rect.left <= event.clientX &&
      event.clientX <= rect.left + rect.width
    );
    if (!isInDialog) {
      regDialog.close();
    }
  });
}

if (regForm) {
  regForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const fullname = document.getElementById('form-fullname').value;
    const email = document.getElementById('form-email').value;
    const org = document.getElementById('form-organisation').value;
    const ticketName = document.getElementById('form-pass-name').value;
    
    // Simulate successful registration
    alert(`Success! Thank you, ${fullname}.\nYour reservation for a ${ticketName} at the Education Summit 2026 has been logged.\nAn confirmation email will be sent to ${email} shortly.`);
    regDialog.close();
    regForm.reset();
  });
}

// Hamburger menu navigation trigger
const hamburger = document.getElementById('hamburger-btn');
const mobileOverlay = document.getElementById('mobile-nav-overlay');

if (hamburger && mobileOverlay) {
  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('is-active');
    mobileOverlay.classList.toggle('is-active');
  });

  // Close mobile nav on link click
  mobileOverlay.addEventListener('click', (e) => {
    if (e.target.tagName === 'A') {
      hamburger.classList.remove('is-active');
      mobileOverlay.classList.remove('is-active');
    }
  });
}

// Header styling shift on scroll
window.addEventListener('scroll', () => {
  const header = document.querySelector('.header');
  const headerCta = document.getElementById('header-cta');
  
  if (window.scrollY > 100) {
    header.style.padding = '0.5rem 0';
    header.style.backgroundColor = 'rgba(255, 255, 255, 0.98)';
    if (headerCta) headerCta.style.display = 'inline-flex';
  } else {
    header.style.padding = '0';
    header.style.backgroundColor = 'rgba(255, 255, 255, 0.92)';
    if (headerCta) headerCta.style.display = 'none';
  }
});

// Initial Render
document.addEventListener('DOMContentLoaded', () => {
  renderPage(window.currentCmsData);
  setupScheduleFilters();
});

// Expose renderPage to window for the live CMS editor panel
window.renderPage = renderPage;
window.renderSchedule = renderSchedule;
