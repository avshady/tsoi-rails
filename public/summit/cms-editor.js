import initialData from './cms-data.js';

// Section mappings matching the 19 landing page sections
const sectionMappings = {
  hero: "1. Hero Section",
  intro: "2. Event Introduction",
  whyAttend: "3. Why Attend?",
  whoShouldAttend: "4. Who Should Attend?",
  experience: "5. The Experience Timeline",
  themes: "6. Event Themes",
  speakers: "7. Speakers Section",
  sessions: "8. Sessions & Formats",
  institutions: "9. Featured Institutions",
  networking: "10. Networking",
  innovationShowcase: "11. Innovation Showcase",
  venue: "12. Venue Details",
  schedule: "13. Event Schedule (Agenda)",
  registration: "14. Registration Passes",
  partners: "15. Partners & Sponsors",
  testimonials: "16. Testimonials",
  faqs: "17. FAQs Accordions",
  ctaSection: "18. Final Call to Action",
  footer: "19. Footer Details"
};

// Helper to get value from nested object path
function getNestedValue(obj, path) {
  return path.split('.').reduce((acc, part) => acc && acc[part], obj);
}

// Helper to set value in nested object path
function setNestedValue(obj, path, value) {
  const parts = path.split('.');
  const lastPart = parts.pop();
  const target = parts.reduce((acc, part) => acc[part], obj);
  if (target) {
    target[lastPart] = value;
  }
}

// Format path names into clean readable form labels
function getFieldLabelFromPath(path) {
  const parts = path.split('.');
  const last = parts[parts.length - 1];
  
  // Camel case to Title Case with spaces
  let label = last
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, str => str.toUpperCase());
    
  // Clean up specific labels
  if (label === 'Desc') label = 'Description';
  if (label === 'Paragraph1') label = 'Paragraph 1';
  if (label === 'Paragraph2') label = 'Paragraph 2';
  if (label === 'Cta Primary') label = 'Primary CTA';
  if (label === 'Cta Secondary') label = 'Secondary CTA';
  
  return label;
}

// Determine label of items inside arrays (like speaker names or day numbers)
function getItemLabel(item, index) {
  if (item && typeof item === 'object') {
    return item.name || item.title || item.day || item.question || item.time || item.quote || item.theme || `Item ${index + 1}`;
  }
  return `Item ${index + 1}`;
}

// Recursively generate HTML fields for any data value type
function renderFieldRecursive(val, path) {
  // 1. Simple String fields
  if (typeof val === 'string') {
    const id = `cms-input-${path.replace(/\./g, '-')}`;
    const label = getFieldLabelFromPath(path);
    
    // Check if the field represents an asset or configuration string that isn't primarily text
    const isPhoto = path.includes('photo');
    const isColor = path.includes('color');
    const isIcon = path.includes('icon');
    const isAction = path.includes('action');
    
    let extraLabelInfo = '';
    if (isPhoto) extraLabelInfo = ' (Image Path)';
    if (isColor) extraLabelInfo = ' (Hex/Color Theme)';
    if (isIcon) extraLabelInfo = ' (Emoji/Icon)';
    if (isAction) extraLabelInfo = ' (Link Anchor)';

    if (val.length > 60 || val.includes('\n') || label.toLowerCase().includes('paragraph') || label.toLowerCase().includes('about') || label.toLowerCase().includes('quote') || label.toLowerCase().includes('answer')) {
      return `
        <div class="form-group" style="gap: 0.25rem; margin-bottom: 0.5rem;">
          <label class="form-label" style="font-size: 0.75rem;" for="${id}">${label}${extraLabelInfo}</label>
          <textarea id="${id}" class="form-input" style="height: 70px; resize: vertical; font-size: 0.85rem;" data-path="${path}" data-type="string">${val}</textarea>
        </div>
      `;
    } else {
      return `
        <div class="form-group" style="gap: 0.25rem; margin-bottom: 0.5rem;">
          <label class="form-label" style="font-size: 0.75rem;" for="${id}">${label}${extraLabelInfo}</label>
          <input type="text" id="${id}" class="form-input" style="font-size: 0.85rem; padding: 0.5rem 0.875rem;" value="${val}" data-path="${path}" data-type="string">
        </div>
      `;
    }
  }

  // 2. Simple Number fields
  if (typeof val === 'number') {
    const id = `cms-input-${path.replace(/\./g, '-')}`;
    return `
      <div class="form-group" style="gap: 0.25rem; margin-bottom: 0.5rem;">
        <label class="form-label" style="font-size: 0.75rem;" for="${id}">${getFieldLabelFromPath(path)}</label>
        <input type="number" id="${id}" class="form-input" style="font-size: 0.85rem; padding: 0.5rem 0.875rem;" value="${val}" data-path="${path}" data-type="number">
      </div>
    `;
  }

  // 3. String Arrays (e.g. whoShouldAttend, themes, features)
  if (Array.isArray(val) && val.every(item => typeof item === 'string')) {
    const id = `cms-input-${path.replace(/\./g, '-')}`;
    return `
      <div class="form-group" style="gap: 0.25rem; margin-bottom: 0.5rem;">
        <label class="form-label" style="font-size: 0.75rem;" for="${id}">${getFieldLabelFromPath(path)} (Comma separated)</label>
        <textarea id="${id}" class="form-input" style="height: 70px; resize: vertical; font-size: 0.85rem;" data-path="${path}" data-type="string-array">${val.join(', ')}</textarea>
      </div>
    `;
  }

  // 4. Arrays of Objects (e.g. whyAttend grid, speakers.list, schedule.Day1, registration)
  if (Array.isArray(val) && val.every(item => typeof item === 'object')) {
    return val.map((item, idx) => {
      const label = getItemLabel(item, idx);
      return `
        <div class="cms-array-item" style="border-left: 2px solid rgba(255,255,255,0.06); padding-left: 0.75rem; margin-top: 0.5rem; margin-bottom: 1rem;">
          <div style="font-size: 0.75rem; font-weight:800; color: var(--color-lime); margin-bottom: 0.5rem; text-transform: uppercase;">${label}</div>
          <div style="display: flex; flex-direction: column; gap: 0.5rem;">
            ${Object.keys(item).map(key => renderFieldRecursive(item[key], `${path}.${idx}.${key}`)).join('')}
          </div>
        </div>
      `;
    }).join('');
  }

  // 5. Nested Objects (e.g. venue, footer, ctaSection, speakers)
  if (typeof val === 'object' && val !== null) {
    return Object.keys(val).map(key => renderFieldRecursive(val[key], `${path}.${key}`)).join('');
  }

  return '';
}

// Build and render the complete list of groups inside the drawer body
function buildCmsForm() {
  const drawerBody = document.querySelector('.cms-drawer-body');
  if (!drawerBody) return;

  let html = '';
  for (const [key, sectionTitle] of Object.entries(sectionMappings)) {
    const dataVal = window.currentCmsData[key];
    if (dataVal === undefined) continue;

    html += `
      <details class="cms-section-group">
        <summary>${sectionTitle}</summary>
        <div class="cms-group-content">
          ${renderFieldRecursive(dataVal, key)}
        </div>
      </details>
    `;
  }
  
  drawerBody.innerHTML = html;
  attachEditorListeners(drawerBody);
}

// Attach event bindings to all dynamically generated inputs
function attachEditorListeners(container) {
  container.querySelectorAll('input, textarea').forEach(input => {
    input.addEventListener('input', (e) => {
      const path = e.target.getAttribute('data-path');
      const type = e.target.getAttribute('data-type');
      let val = e.target.value;

      if (type === 'string-array') {
        val = val.split(',').map(s => s.trim()).filter(s => s.length > 0);
      } else if (type === 'number') {
        val = Number(val);
      }

      setNestedValue(window.currentCmsData, path, val);

      // Trigger instant re-render of the landing page
      if (window.renderPage) {
        window.renderPage(window.currentCmsData);
      }
      
      // Also refresh schedule if any of Day1/Day2/Day3 values changed
      if (path.includes('schedule') && window.renderSchedule) {
        const activeTab = document.querySelector('.schedule-tab.is-active');
        const day = activeTab ? activeTab.getAttribute('data-day') : 'Day1';
        window.renderSchedule(window.currentCmsData.schedule, day);
      }
      
      // Auto-save changes back to cms-data.js on the filesystem
      saveCmsDataToServer();
    });
  });
}

// Read the Rails CSRF token embedded in the page head so state-changing
// requests (auth + save) are accepted by the server.
function csrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

let saveTimeout;
function saveCmsDataToServer() {
  clearTimeout(saveTimeout);
  saveTimeout = setTimeout(() => {
    fetch('/summit/cms/save', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken()
      },
      body: JSON.stringify(window.currentCmsData)
    })
    .then(res => res.json())
    .then(res => {
      if (res.ok) {
        console.log('CMS data saved to database:', res.message);
      } else {
        console.error('CMS save rejected:', res.message);
      }
    })
    .catch(err => {
      console.error('Failed to save CMS data:', err);
    });
  }, 1000); // 1-second debounce
}

// Render locked console security interface
function renderPasswordScreen() {
  const drawerBody = document.querySelector('.cms-drawer-body');
  if (!drawerBody) return;
  
  drawerBody.innerHTML = `
    <div class="cms-lock-screen" style="display: flex; flex-direction: column; gap: 1.5rem; justify-content: center; height: 70%; text-align: center; padding: 2rem 1rem;">
      <div style="font-size: 3rem;">🔒</div>
      <div>
        <h4 style="font-size: 1.2rem; font-weight:800; margin-bottom:0.5rem; color: var(--text-white);">CMS Console Locked</h4>
        <p style="font-size: 0.85rem; color: var(--text-muted); line-height: 1.4;">Enter the administrator passcode to unlock website editing tools.</p>
      </div>
      <form id="cms-unlock-form" style="display:flex; flex-direction:column; gap:1rem;">
        <div class="form-group" style="text-align: left;">
          <label class="form-label" style="font-size: 0.75rem;" for="cms-passcode-input">Passcode</label>
          <input type="password" id="cms-passcode-input" class="form-input" style="font-size:0.95rem; padding: 0.65rem 0.875rem;" placeholder="Enter password" required>
          <p id="cms-error-msg" style="color: var(--color-magenta); font-size: 0.75rem; margin-top: 0.25rem; display: none;">Incorrect passcode. Please try again.</p>
        </div>
        <button type="submit" class="btn btn-primary" style="padding: 0.65rem; font-size:0.9rem; border-radius:0.5rem;">Unlock Console</button>
      </form>
    </div>
  `;

  const form = document.getElementById('cms-unlock-form');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const input   = document.getElementById('cms-passcode-input');
    const passcode = input.value;

    // The passcode is verified on the SERVER — it is never stored in this file.
    // A correct passcode unlocks the session so subsequent saves are accepted.
    let ok = false;
    try {
      const res = await fetch('/summit/cms/auth', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken()
        },
        body: JSON.stringify({ password: passcode })
      });
      ok = res.ok;
    } catch (err) {
      ok = false;
    }

    if (ok) {
      sessionStorage.setItem('cms_unlocked', 'true');
      buildCmsForm(); // Render editing fields

      // Reveal action buttons
      document.getElementById('cms-reset-btn').style.display = 'block';
      document.getElementById('cms-copy-btn').style.display = 'block';
    } else {
      const errorMsg = document.getElementById('cms-error-msg');
      errorMsg.style.display = 'block';
      input.style.borderColor = 'var(--color-magenta)';
      input.value = '';

      // Trigger shake warning
      input.parentElement.classList.add('shake');
      setTimeout(() => {
        input.parentElement.classList.remove('shake');
      }, 500);
    }
  });
}

// Drawer visibility toggle handlers
function setupDrawerControls() {
  const drawer = document.getElementById('cms-drawer');
  const toggleBtn = document.getElementById('cms-toggle-btn');
  const closeBtn = document.getElementById('cms-drawer-close');
  const copyBtn = document.getElementById('cms-copy-btn');
  const resetBtn = document.getElementById('cms-reset-btn');
  const toast = document.getElementById('toast-message');

  if (!drawer || !toggleBtn) return;

  toggleBtn.addEventListener('click', () => {
    drawer.classList.add('is-open');
    
    // Check if user is already authenticated this session
    const isUnlocked = sessionStorage.getItem('cms_unlocked') === 'true';
    if (isUnlocked) {
      buildCmsForm();
      resetBtn.style.display = 'block';
      copyBtn.style.display = 'block';
    } else {
      renderPasswordScreen();
      resetBtn.style.display = 'none';
      copyBtn.style.display = 'none';
    }
  });

  closeBtn.addEventListener('click', () => {
    drawer.classList.remove('is-open');
  });

  // Export JSON copy functionality
  copyBtn.addEventListener('click', () => {
    const jsonString = JSON.stringify(window.currentCmsData, null, 2);
    navigator.clipboard.writeText(jsonString).then(() => {
      toast.classList.add('is-visible');
      setTimeout(() => {
        toast.classList.remove('is-visible');
      }, 3000);
    }).catch(err => {
      console.error('Failed to copy CMS data: ', err);
      alert('Failed to copy to clipboard. Full JSON data printed to console.');
      console.log(jsonString);
    });
  });

  // Reset functionality
  resetBtn.addEventListener('click', () => {
    if (confirm('Are you sure you want to discard your edits and reset the CMS data to its defaults?')) {
      window.currentCmsData = JSON.parse(JSON.stringify(initialData));
      buildCmsForm(); // Rebuild form fields
      
      if (window.renderPage) {
        window.renderPage(window.currentCmsData);
      }
      if (window.renderSchedule) {
        const activeTab = document.querySelector('.schedule-tab.is-active');
        const day = activeTab ? activeTab.getAttribute('data-day') : 'Day1';
        window.renderSchedule(window.currentCmsData.schedule, day);
      }
      
      saveCmsDataToServer();
    }
  });

  // Close drawer if user clicks outside of it
  document.addEventListener('click', (e) => {
    if (drawer.classList.contains('is-open') && 
        !drawer.contains(e.target) && 
        !toggleBtn.contains(e.target) &&
        !e.target.closest('dialog')) {
      drawer.classList.remove('is-open');
    }
  });
}

// Initialize drawer on DOM load
document.addEventListener('DOMContentLoaded', () => {
  setupDrawerControls();
});
