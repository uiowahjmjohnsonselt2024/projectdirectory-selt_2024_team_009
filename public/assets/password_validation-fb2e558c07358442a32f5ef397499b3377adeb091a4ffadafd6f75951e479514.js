document.addEventListener("DOMContentLoaded", () => {
    const passwordInput = document.querySelector("#user_password");
    const confirmPasswordInput = document.querySelector("#user_password_confirmation");
    const passwordRequirements = document.querySelector("#password-requirements");
    const confirmMessage = document.querySelector("#confirm-message");

    if (passwordInput && confirmPasswordInput && passwordRequirements && confirmMessage) {
        passwordInput.addEventListener("input", () => {
            const password = passwordInput.value;
            if (password.length < 8 || !/\d/.test(password) || !/[!@#$%^&*]/.test(password)) {
                passwordRequirements.textContent = "Password must be at least 8 characters long, include a number, and a special character.";
                passwordRequirements.style.color = "red";
            } else {
                passwordRequirements.textContent = "Password meets the requirements.";
                passwordRequirements.style.color = "green";
            }
        });

        confirmPasswordInput.addEventListener("input", () => {
            if (confirmPasswordInput.value !== passwordInput.value) {
                confirmMessage.textContent = "Passwords do not match.";
                confirmMessage.style.color = "red";
            } else {
                confirmMessage.textContent = "Passwords match!";
                confirmMessage.style.color = "green";
            }
        });
    }
});
