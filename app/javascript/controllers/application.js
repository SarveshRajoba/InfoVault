import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = false
window.Stimulus   = application


// document.addEventListener('DOMContentLoaded', function() {
//   const dropdownToggles = document.querySelectorAll('[data-bs-toggle="dropdown"]');

//   dropdownToggles.forEach(toggle => {
//     toggle.addEventListener('click', function() {
//       const dropdownId = this.getAttribute('data-dropdown-id');
//       const dropdownMenu = document.getElementById(dropdownId);

//       if (dropdownMenu) {
//         document.body.appendChild(dropdownMenu);

//         const rect = this.getBoundingClientRect();
//         dropdownMenu.style.position = 'fixed';
//         dropdownMenu.style.left = `${rect.left}px`;
//         dropdownMenu.style.top = `${rect.bottom}px`;
//         dropdownMenu.style.zIndex = '10000';
//       }
//     });
//   });
// });

export { application }
