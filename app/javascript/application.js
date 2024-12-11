import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = true

import "channels"
import "controllers"
import "./chatbox"