const BRANCHES = ['unstable', 'release-25.11'];
let fuse = null;
let allPackages = [];
let expandedPackage = null;

async function loadPackages(branch) {
  try {
    const response = await fetch(`data/${branch}/packages.json`);
    if (!response.ok) {
      if (branch !== 'unstable') {
        console.warn(`Branch ${branch} not found, falling back to unstable`);
        document.getElementById('branch').value = 'unstable';
        return loadPackages('unstable');
      }
      throw new Error(`HTTP ${response.status}`);
    }
    const data = await response.json();

    allPackages = Object.entries(data).map(([name, pkg]) => ({
      name,
      ...pkg
    }));

    fuse = new Fuse(allPackages, {
      keys: [
        { name: 'name', weight: 0.4 },
        { name: 'pname', weight: 0.3 },
        { name: 'meta.description', weight: 0.2 },
        { name: 'meta.homepage', weight: 0.1 }
      ],
      threshold: 0.4,
      includeScore: true
    });

    expandedPackage = null;
    render(allPackages);
    updateURL();
  } catch (error) {
    document.getElementById('results').innerHTML =
      `<p style="color: #f85149;">Error loading packages: ${error.message}</p>`;
    document.getElementById('count').textContent = '';
  }
}

function render(packages) {
  const resultsEl = document.getElementById('results');
  const countEl = document.getElementById('count');

  countEl.textContent = `${packages.length} packages`;

  if (packages.length === 0) {
    resultsEl.innerHTML = '<p>No packages found</p>';
    return;
  }

  resultsEl.innerHTML = packages.slice(0, 100).map(pkg => {
    const p = pkg.item || pkg;
    const meta = p.meta || {};
    const isExpanded = expandedPackage === p.name;

    return `
      <div class="package ${isExpanded ? 'expanded' : ''}" onclick="togglePackage('${escapeHtml(p.name)}')">
        <div class="package-header">
          <span class="package-name">${escapeHtml(p.name)}</span>
          <span class="package-version">${escapeHtml(p.version)}</span>
        </div>
        ${meta.description ? `<p class="package-description">${escapeHtml(meta.description)}</p>` : ''}
        ${isExpanded ? renderDetails(p) : ''}
        <div class="package-meta">
          ${meta.homepage ? `<a href="${escapeHtml(meta.homepage)}" target="_blank" onclick="event.stopPropagation()">${escapeHtml(meta.homepage)}</a>` : ''}
          ${renderLicenseBadge(meta.license)}
        </div>
      </div>
    `;
  }).join('');
}

function renderLicenseBadge(license) {
  if (!license) return '';
  const name = license.spdxId || license.shortName || license.fullName;
  if (!name) return '';
  const isFree = license.free !== false;
  return ` · <span class="license-badge ${isFree ? '' : 'unfree'}">${escapeHtml(name)}</span>`;
}

function renderDetails(pkg) {
  const branch = document.getElementById('branch').value;
  const meta = pkg.meta || {};

  return `
    <div class="package-details">
      <h4>Installation</h4>
      <div class="code-block">
        <code>nix shell github:mulatta/toolz/${branch}#${pkg.name}</code>
        <button class="copy-btn" onclick="copyToClipboard('nix shell github:mulatta/toolz/${branch}#${pkg.name}', event)">Copy</button>
      </div>
      <div class="code-block">
        <code>nix run github:mulatta/toolz/${branch}#${pkg.name}</code>
        <button class="copy-btn" onclick="copyToClipboard('nix run github:mulatta/toolz/${branch}#${pkg.name}', event)">Copy</button>
      </div>

      ${meta.longDescription ? `
        <h4>Long Description</h4>
        <p class="long-description">${escapeHtml(meta.longDescription)}</p>
      ` : ''}

      <h4>Package Info</h4>
      <table class="info-table">
        <tr><td>Attribute</td><td><code>${escapeHtml(pkg.name)}</code></td></tr>
        <tr><td>Package Name</td><td>${escapeHtml(pkg.pname)}</td></tr>
        <tr><td>Version</td><td>${escapeHtml(pkg.version)}</td></tr>
        ${meta.homepage ? `<tr><td>Homepage</td><td><a href="${escapeHtml(meta.homepage)}" target="_blank" onclick="event.stopPropagation()">${escapeHtml(meta.homepage)}</a></td></tr>` : ''}
        ${renderLicenseRow(meta.license)}
        ${renderMaintainersRow(meta.maintainers)}
        ${renderPlatformsRow(meta.platforms)}
        ${meta.broken ? '<tr><td>Status</td><td><span class="badge broken">Broken</span></td></tr>' : ''}
        ${meta.unfree ? '<tr><td>License Type</td><td><span class="badge unfree">Unfree</span></td></tr>' : ''}
      </table>
    </div>
  `;
}

function renderLicenseRow(license) {
  if (!license) return '';

  if (Array.isArray(license)) {
    const names = license.map(l => l.fullName || l.spdxId || l.shortName).filter(Boolean);
    if (names.length === 0) return '';
    return `<tr><td>License</td><td>${names.map(n => escapeHtml(n)).join(', ')}</td></tr>`;
  }

  const parts = [];
  if (license.fullName) parts.push(license.fullName);
  else if (license.spdxId) parts.push(license.spdxId);
  else if (license.shortName) parts.push(license.shortName);

  if (parts.length === 0) return '';

  const badges = [];
  if (license.free === true) badges.push('<span class="badge free">Free</span>');
  if (license.free === false) badges.push('<span class="badge unfree">Unfree</span>');
  if (license.redistributable === true) badges.push('<span class="badge">Redistributable</span>');

  return `<tr><td>License</td><td>${escapeHtml(parts[0])} ${badges.join(' ')}</td></tr>`;
}

function renderMaintainersRow(maintainers) {
  if (!maintainers || maintainers.length === 0) return '';

  const rendered = maintainers.map(m => {
    if (!m) return null;
    const parts = [];
    if (m.name) parts.push(m.name);
    if (m.github) {
      parts.push(`<a href="https://github.com/${escapeHtml(m.github)}" target="_blank" onclick="event.stopPropagation()">@${escapeHtml(m.github)}</a>`);
    }
    if (m.email && !m.github) {
      parts.push(`<a href="mailto:${escapeHtml(m.email)}" onclick="event.stopPropagation()">${escapeHtml(m.email)}</a>`);
    }
    return parts.join(' ');
  }).filter(Boolean);

  if (rendered.length === 0) return '';
  return `<tr><td>Maintainers</td><td>${rendered.join('<br>')}</td></tr>`;
}

function renderPlatformsRow(platforms) {
  if (!platforms || platforms.length === 0) return '';

  // Group by architecture
  const grouped = {};
  platforms.forEach(p => {
    const [arch, os] = p.split('-');
    if (!grouped[os]) grouped[os] = [];
    grouped[os].push(arch);
  });

  const summary = Object.entries(grouped).map(([os, archs]) => {
    if (archs.length > 3) {
      return `${os} (${archs.length} archs)`;
    }
    return `${os}: ${archs.join(', ')}`;
  }).join('; ');

  return `<tr><td>Platforms</td><td>${escapeHtml(summary)}</td></tr>`;
}

function togglePackage(name) {
  expandedPackage = expandedPackage === name ? null : name;
  const query = document.getElementById('search').value;
  if (!query.trim()) {
    render(allPackages);
  } else {
    render(fuse.search(query));
  }
}

function copyToClipboard(text, event) {
  event.stopPropagation();
  navigator.clipboard.writeText(text).then(() => {
    const btn = event.target;
    const original = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => btn.textContent = original, 1500);
  });
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function search(query) {
  expandedPackage = null;
  if (!query.trim()) {
    render(allPackages);
  } else {
    render(fuse.search(query));
  }
  updateURL();
}

function updateURL() {
  const branch = document.getElementById('branch').value;
  const query = document.getElementById('search').value;
  const params = new URLSearchParams();
  if (branch !== 'unstable') params.set('branch', branch);
  if (query) params.set('q', query);
  const url = params.toString() ? `?${params}` : location.pathname;
  history.replaceState(null, '', url);
}

function loadFromURL() {
  const params = new URLSearchParams(location.search);
  const branch = params.get('branch') || 'unstable';
  const query = params.get('q') || '';

  document.getElementById('branch').value = branch;
  document.getElementById('search').value = query;

  return { branch, query };
}

document.addEventListener('DOMContentLoaded', () => {
  const { branch, query } = loadFromURL();

  document.getElementById('branch').addEventListener('change', (e) => {
    loadPackages(e.target.value);
  });

  document.getElementById('search').addEventListener('input', (e) => {
    search(e.target.value);
  });

  loadPackages(branch).then(() => {
    if (query) search(query);
  });
});
