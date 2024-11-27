// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// Import Turbo Drive for partial page updates and navigation
import "@hotwired/turbo-rails";

// Import Stimulus for JavaScript controllers
import { Application } from "@hotwired/stimulus";
import { definitionsFromContext } from "@hotwired/stimulus-loading";

// Set up Stimulus
const application = Application.start();
const context = require.context("controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

// Import Bootstrap for UI components
import "bootstrap";

import "./password_validation"

// Import Popper.js for Bootstrap's dropdowns, tooltips, and popovers
import "@popperjs/core";
import "controllers";

import "./password_strength";
import "./password_strength";

