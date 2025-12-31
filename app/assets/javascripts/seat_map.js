document.addEventListener("DOMContentLoaded", function () {
  const MAX = 6;
  const selectedSeats = new Set();
  const hiddenInput = document.getElementById("selected-seats");
  const confirmBtn = document.getElementById("confirm-btn");
  const seats = document.querySelectorAll(".seat");

  seats.forEach(function (btn) {
    btn.addEventListener("click", function () {
      const seat = btn.dataset.seat;

      // すでに選択済み → 解除
      if (selectedSeats.has(seat)) {
        selectedSeats.delete(seat);
        btn.classList.remove("selected");
      } else {
        // 6席制限
        if (selectedSeats.size >= MAX) {
          alert("1回の予約で選択できるのは6席までです");
          return;
        }

        selectedSeats.add(seat);
        btn.classList.add("selected");
      }

      updateDisabled(seats, selectedSeats, MAX);
      updateForm(hiddenInput, confirmBtn, selectedSeats);
    });
  });
});

function updateDisabled(seats, selectedSeats, MAX) {
  seats.forEach(function (btn) {
    if (!btn.classList.contains("selected")) {
      btn.disabled = selectedSeats.size >= MAX;
    }
  });
}

function updateForm(hiddenInput, confirmBtn, selectedSeats) {
  if (hiddenInput) {
    hiddenInput.value = Array.from(selectedSeats).join(",");
  }

  if (confirmBtn) {
    confirmBtn.style.display =
      selectedSeats.size > 0 ? "block" : "none";
  }
}
