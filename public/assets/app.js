'use strict';

for (const form of document.querySelectorAll('form[data-confirm]')) {
    form.addEventListener('submit', event => {
        if (!window.confirm(form.dataset.confirm)) {
            event.preventDefault();
        }
    });
}

const attendanceButton = document.querySelector('[data-mark-present]');
attendanceButton?.addEventListener('click', () => {
    for (const status of document.querySelectorAll('.attendance-select')) {
        if (status.value === '' && status.dataset.existing === '') {
            status.value = 'Present';
        }
    }
});

document.querySelector('[data-print]')?.addEventListener('click', () => window.print());

for (const button of document.querySelectorAll('[data-demo-email]')) {
    button.addEventListener('click', () => {
        document.querySelector('#email').value = button.dataset.demoEmail;
        document.querySelector('#password').value = document.querySelector('#demo-password').textContent;
        document.querySelector('#email').focus();
    });
}
