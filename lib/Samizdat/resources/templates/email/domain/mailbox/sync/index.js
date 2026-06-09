(function() {
  const modalDialog = document.querySelector('#modalDialog');
  const sourceUrl = modalDialog?.dataset.sourceUrl || '';

  // Extract domain + username from /email/{domain}/mailbox/{username}/sync
  const pathMatch = sourceUrl.match(/\/email\/([^/]+)\/mailbox\/([^/]+)\/sync$/);
  const domain = pathMatch ? decodeURIComponent(pathMatch[1]) : null;
  const mailbox = pathMatch ? decodeURIComponent(pathMatch[2]) : null;

  const form = document.getElementById('mailboxSyncForm');
  const startBtn = document.getElementById('syncStartBtn');
  const result = document.getElementById('syncResult');

  function showResult(message, level) {
    result.className = 'alert mt-3 alert-' + (level || 'info');
    result.textContent = message;
    result.classList.remove('d-none');
  }

  // Pre-fill source username with mailbox username as a common starting point
  const srcUser = document.getElementById('src_user');
  if (srcUser && !srcUser.value && mailbox) {
    srcUser.value = mailbox;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const payload = {
      source: {
        host:     document.getElementById('src_host').value.trim(),
        port:     parseInt(document.getElementById('src_port').value, 10) || 993,
        user:     document.getElementById('src_user').value.trim(),
        password: document.getElementById('src_password').value,
        ssl:      document.getElementById('src_ssl').checked
      },
      dest: {
        host:     document.getElementById('dst_host').value.trim(),
        port:     parseInt(document.getElementById('dst_port').value, 10) || 993,
        user:     document.getElementById('dst_user').value.trim(),
        password: document.getElementById('dst_password').value,
        ssl:      document.getElementById('dst_ssl').checked
      },
      dry_run:       document.getElementById('dry_run').checked,
      delete_source: document.getElementById('delete_source').checked,
      skip_existing: document.getElementById('skip_existing').checked
    };

    startBtn.disabled = true;
    showResult('<%== __("Enqueuing sync job...") %>', 'info');

    const url = `<%== url_for('Email.mailboxes.sync', domain => '_DOM_', username => '_USR_') %>`
      .replace('_DOM_', encodeURIComponent(domain))
      .replace('_USR_', encodeURIComponent(mailbox));

    const response = await window.authenticatedFetch(url, {
      method: 'POST',
      body: JSON.stringify(payload),
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    });

    startBtn.disabled = false;

    if (response && response.success) {
      showResult(
        '<%== __("Sync job enqueued") %> — ' + '<%== __("Job ID") %>: ' + response.job_id,
        'success'
      );
      window.showToast(response.message || '<%== __("Sync job enqueued") %>');
    } else {
      showResult(response?.error || '<%== __("Failed to enqueue sync job") %>', 'danger');
    }
  });
})();
