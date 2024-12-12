import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true

import "channels"
import "controllers"
import "./chatbox" // Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Explicitly register GameActionsController
import GameActionsController from "controllers/game_actions_controller";
application.register("game-actions", GameActionsController);
