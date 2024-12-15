import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true

import "channels"
import "controllers"
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
