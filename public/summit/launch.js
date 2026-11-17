const toggle = document.querySelector('.menu-toggle');
const nav = document.querySelector('#navigation');
const closeMenu = () => {
  nav.classList.remove('open');
  toggle.setAttribute('aria-expanded', 'false');
};
toggle.addEventListener('click', () => {
  const open = toggle.getAttribute('aria-expanded') !== 'true';
  nav.classList.toggle('open', open);
  toggle.setAttribute('aria-expanded', String(open));
});
nav.querySelectorAll('a').forEach(link => link.addEventListener('click', closeMenu));
document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
    closeMenu();
    toggle.focus();
  }
});
// Keep campaign attribution attached to the existing Rails enquiry journey.
const query = new URLSearchParams(window.location.search);
for (const form of document.querySelectorAll('.enquiry-form')) {
  for (const key of ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'fbclid', 'li_fat_id']) {
    if (!query.has(key)) continue;
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = key;
    input.value = query.get(key);
    form.append(input);
  }
}

// Reveal the policy when an enquiry links directly to the collapsed details.
const revealLinkedDetails = () => {
  const target = document.getElementById(window.location.hash.slice(1));
  if (target?.tagName === 'DETAILS') target.open = true;
};
window.addEventListener('hashchange', revealLinkedDetails);
revealLinkedDetails();
const alert = document.querySelector('.form-alert');
if (alert) {
  alert.setAttribute('tabindex', '-1');
  alert.focus();
}

// Preserve the original one-at-a-time FAQ accordion, with accessible state.
const faqItems = document.querySelectorAll('.faq-item');
for (const item of faqItems) {
  const trigger = item.querySelector('.faq-trigger');
  trigger.addEventListener('click', () => {
    const open = !item.classList.contains('is-active');
    for (const other of faqItems) {
      const active = other === item && open;
      other.classList.toggle('is-active', active);
      other.querySelector('.faq-trigger').setAttribute('aria-expanded', String(active));
      other.querySelector('.faq-panel').inert = !active;
    }
  });
}

// Only one participation band is expanded at a time.
const experienceTabs = [...document.querySelectorAll('.panel-tab')];
const activateExperience = tab => {
  for (const button of experienceTabs) {
    const active = button === tab;
    button.setAttribute('aria-expanded', String(active));
    button.closest('.participation-panel').classList.toggle('is-active', active);
    document.getElementById(button.getAttribute('aria-controls')).hidden = !active;
  }
};
for (const [index, tab] of experienceTabs.entries()) {
  tab.addEventListener('click', () => activateExperience(tab));
  tab.addEventListener('keydown', event => {
    let next;
    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') next = (index + 1) % experienceTabs.length;
    if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') next = (index - 1 + experienceTabs.length) % experienceTabs.length;
    if (event.key === 'Home') next = 0;
    if (event.key === 'End') next = experienceTabs.length - 1;
    if (next !== undefined) {
      event.preventDefault();
      experienceTabs[next].focus();
      activateExperience(experienceTabs[next]);
    }
  });
}
