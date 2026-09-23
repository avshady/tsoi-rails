const tabButtons = document.querySelectorAll('.tab-button[role="tab"]');
const panels = document.querySelectorAll('.people-panel');

tabButtons.forEach((button) => {
  button.addEventListener('click', () => {
    tabButtons.forEach((item) => {
      item.classList.remove('active');
      item.setAttribute('aria-selected', 'false');
    });
    panels.forEach((panel) => {
      panel.classList.remove('active');
      panel.hidden = true;
    });
    button.classList.add('active');
    button.setAttribute('aria-selected', 'true');
    const panel = document.getElementById(button.getAttribute('aria-controls'));
    panel.hidden = false;
    panel.classList.add('active');
  });
});

document.querySelectorAll('[data-journey]').forEach((journey) => {
  const dayButtons = journey.querySelectorAll('.journey-tab');
  const dayPanels = journey.querySelectorAll('.journey-panel');
  const dayTabs = journey.querySelector('.journey-tabs');
  const mobileJourney = window.matchMedia('(max-width: 720px)');
  let mobileLayoutActive = null;

  const syncJourneyLayout = () => {
    if (mobileLayoutActive === mobileJourney.matches) return;
    mobileLayoutActive = mobileJourney.matches;
    if (mobileLayoutActive) {
      dayButtons.forEach((button) => {
        const panel = journey.querySelector(`#${button.getAttribute('aria-controls')}`);
        button.insertAdjacentElement('afterend', panel);
      });
    } else {
      dayPanels.forEach((panel) => journey.appendChild(panel));
    }
  };

  syncJourneyLayout();
  mobileJourney.addEventListener('change', syncJourneyLayout);

  dayButtons.forEach((button) => {
    button.addEventListener('click', () => {
      dayButtons.forEach((item) => {
        item.classList.remove('active');
        item.setAttribute('aria-selected', 'false');
      });
      dayPanels.forEach((panel) => {
        panel.classList.remove('active');
        panel.hidden = true;
      });
      button.classList.add('active');
      button.setAttribute('aria-selected', 'true');
      const panel = journey.querySelector(`#${button.getAttribute('aria-controls')}`);
      panel.hidden = false;
      panel.classList.add('active');
    });
  });
});

document.querySelectorAll('.faq-item button').forEach((button) => {
  button.addEventListener('click', () => {
    const selectedItem = button.closest('.faq-item');
    const willOpen = !selectedItem.classList.contains('open');
    document.querySelectorAll('.faq-item').forEach((item) => {
      item.classList.remove('open');
      item.querySelector('button').setAttribute('aria-expanded', 'false');
    });
    if (willOpen) {
      selectedItem.classList.add('open');
      button.setAttribute('aria-expanded', 'true');
    }
  });
});

const query = new URLSearchParams(window.location.search);
const attributionKeys = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'fbclid', 'li_fat_id'];

document.querySelectorAll('.lead-form').forEach((form) => {
  attributionKeys.forEach((key) => {
    const input = form.querySelector(`[name="${key}"]`);
    if (input) input.value = query.get(key) || '';
  });

  const phone = form.querySelector('[name="phone"]');
  phone.addEventListener('input', () => {
    phone.value = phone.value.replace(/[^0-9+\s-]/g, '').slice(0, 18);
    phone.setCustomValidity('');
  });

  form.addEventListener('submit', (event) => {
    const digits = phone.value.replace(/\D/g, '');
    if (digits.length < 10) {
      event.preventDefault();
      phone.setCustomValidity('Enter a valid 10-digit mobile number.');
      phone.reportValidity();
      return;
    }
    const pageSection = form.dataset.pageSection;
    const pageField = form.querySelector('[name="page_section"]');
    if (pageField) pageField.value = pageSection;
  });
});

document.querySelectorAll('.track-register').forEach((link) => {
  link.addEventListener('click', () => {
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({ event: 'InitiateCheckout', destination: 'TezTicket' });
    if (typeof window.fbq === 'function') window.fbq('track', 'InitiateCheckout');
  });
});

const sticky = document.getElementById('mobile-sticky');
const forms = document.querySelectorAll('.lead-form');
if ('IntersectionObserver' in window && sticky) {
  const visibleForms = new Set();
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => entry.isIntersecting ? visibleForms.add(entry.target) : visibleForms.delete(entry.target));
    sticky.classList.toggle('hidden', visibleForms.size > 0);
  }, { threshold: 0.18 });
  forms.forEach((form) => observer.observe(form));
}

const faqEntities = [...document.querySelectorAll('.faq-item')].map((item) => ({
  '@type': 'Question',
  name: item.querySelector('button span').textContent.trim(),
  acceptedAnswer: {
    '@type': 'Answer',
    text: item.querySelector('.faq-answer p').textContent.trim()
  }
}));
if (faqEntities.length) {
  const faqSchema = document.createElement('script');
  faqSchema.type = 'application/ld+json';
  faqSchema.textContent = JSON.stringify({ '@context': 'https://schema.org', '@type': 'FAQPage', mainEntity: faqEntities });
  document.head.appendChild(faqSchema);
}
