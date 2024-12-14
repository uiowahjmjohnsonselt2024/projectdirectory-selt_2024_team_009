import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true

import "channels"
import "controllers"
import "./chatbox" // Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
