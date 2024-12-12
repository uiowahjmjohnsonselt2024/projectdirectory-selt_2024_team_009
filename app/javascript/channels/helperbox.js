// /app/assets/javascript/channels/helperbox.js
// This file is to allow for the helper box to update upon hovering over a button.

// The core idea is as follows:
// - Take every button on a web page and append a hover listener.
// - The listener checks if the "title" attribute is null. If it is, do not do anything.
// - Otherwise, get the p helpertext, and set it to what the title is.

// This program may be extended to ALL attributes on the page, however, this will likely result in performance issues.

helpBoss = document.getElementById('helphead');
helperText = document.getElementById('helptext')

document.addEventListener('DOMContentLoaded', () => {
    console.log("I think I am working")
    // Select all buttons on the page
    const types =  ['a', 'input', 'select', 'button', 'h2']

    types.forEach(type => {
        console.log(type);
        const elements = document.querySelectorAll(type);
        console.log(elements.size)
        elements.forEach(elem => {
            elem.addEventListener('mouseenter', () => {
              const title = elem.getAttribute('title');
        
              if (title) {
                helpBoss.textContent = "T9 Bot Says"
                helperText.textContent = title; // Update the helper text
              }
            });
        
            elem.addEventListener('mouseleave', () => {
              helpBoss.textContent = "Help"
              helperText.textContent = 'If you are unsure how to use this application, hover over a button. (or maybe the button doesn\'t have a description)'; // Clear the helper text
            });
          });        
    })
});