document.addEventListener("DOMContentLoaded", function () {
  const seatMap = document.getElementById("seat-map");
  if (!seatMap) return;

  const carType = seatMap.dataset.carType;

  // 上限決定
  let MAX;
  if (carType === "fabulous") {
    MAX = 1;
  } else {
    MAX = 6; // reserved / green
  }

  const selectedSeats = new Set();
  const hiddenInput = document.getElementById("selected-seats");
  const confirmBtn = document.getElementById("confirm-btn");
  const seats = document.querySelectorAll(".seat");

  seats.forEach(function (btn) {
    btn.addEventListener("click", function () {
      const seatId = btn.dataset.seat;

      // 解除
      if (selectedSeats.has(seatId)) {
        selectedSeats.delete(seatId);
        btn.classList.remove("selected");
      } else {
        if (selectedSeats.size >= MAX) {
          alert(
            carType === "fabulous"
              ? "ファビュラスルームは1室のみ選択できます"
              : "1回の予約で選択できるのは6席までです"
          );
          return;
        }

        selectedSeats.add(seatId);
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
  hiddenInput.value = Array.from(selectedSeats).join(",");
  confirmBtn.style.display = selectedSeats.size > 0 ? "block" : "none";
}
