document.addEventListener("DOMContentLoaded", function () {
  var buttons = document.querySelectorAll(".password-toggle");

  buttons.forEach(function (button) {
    button.addEventListener("click", function () {
      var targetId = button.getAttribute("data-target");
      var input = document.getElementById(targetId);

      if (!input) {
        return;
      }

      if (input.type === "password") {
        input.type = "text";
        button.textContent = "🙈";
      } else {
        input.type = "password";
        button.textContent = "👁";
      }
    });
  });
});
