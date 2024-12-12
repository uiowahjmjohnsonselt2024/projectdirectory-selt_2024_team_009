// /app/assets/javascript/channels/helperbox.js
// This file is to allow for the helper box to update upon hovering over a button.

// The core idea is as follows:
// - Take every button on a web page and append a hover listener.
// - The listener checks if the "title" attribute is null. If it is, do not do anything.
// - Otherwise, get the p helpertext, and set it to what the title is.

// This program may be extended to ALL attributes on the page, however, this will likely result in performance issues.

document.addEventListener('DOMContentLoaded', () => {
    console.log("I think I am working")
    // Select all buttons on the page
    const links = document.querySelectorAll('a');
  
    // Select the helper text element
    const helperText = document.getElementById('helptext');
  
    if (!helperText) {
      console.warn('Helper text element not found. Please add a <p class="helptext"> element to your HTML.');
      return;
    }
    console.log("I think I am working2")

  
  // Add hover listeners to all links
  links.forEach(link => {
    link.addEventListener('mouseenter', () => {
        console.log("ADDED YEE!")
      const title = link.getAttribute('title');

      if (title) {
        helperText.textContent = title; // Update the helper text
      }
    });

    link.addEventListener('mouseleave', () => {
      helperText.textContent = 'If you are unsure how to use this application, hover over a button.'; // Clear the helper text
    });
  });
});