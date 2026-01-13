document.addEventListener("DOMContentLoaded", function () {
  const seatMap = document.getElementById("seat-map");
  if (!seatMap) return;

  const carType = seatMap.dataset.carType;

  // 上限決定
  let MAX;
  if (carType === "fabulous") {
    MAX = 1;
  } else {
    MAX = 6;
  }

  const selectedSeats = new Set();
  const hiddenInput = document.getElementById("selected-seats");
  const confirmBtn = document.getElementById("confirm-btn");
  const seats = document.querySelectorAll(".seat");
  const messageBox = document.getElementById("seat-message");

  function showMessage(text) {
    messageBox.textContent = text;
    messageBox.style.display = "block";
  }

  function clearMessage() {
    messageBox.style.display = "none";
  }

  seats.forEach(function (btn) {
    btn.addEventListener("click", function () {
      if (
        btn.classList.contains("unavailable") ||
        btn.classList.contains("limit-disabled")
      ) {
        return;
      }

      const seatId = btn.dataset.seat;

      // 解除
      if (selectedSeats.has(seatId)) {
        selectedSeats.delete(seatId);
        btn.classList.remove("selected");
        clearMessage();
      } else {
        if (selectedSeats.size >= MAX) {
          showMessage(
            carType === "fabulous"
              ? "ファビュラスルームは1室のみ選択できます"
              : "1回の予約で選択できるのは6席までです"
          );
          return;
        }

        selectedSeats.add(seatId);
        btn.classList.add("selected");
        clearMessage();
      }

      updateDisabled(seats, selectedSeats, MAX);
      updateForm(hiddenInput, confirmBtn, selectedSeats);
    });
  });
});

function updateDisabled(seats, selectedSeats, MAX) {
  seats.forEach(function (btn) {
    if (btn.classList.contains("unavailable")) return;

    if (!btn.classList.contains("selected")) {
      if (selectedSeats.size >= MAX) {
        btn.classList.add("limit-disabled");
      } else {
        btn.classList.remove("limit-disabled");
      }
    }
  });
}

function updateForm(hiddenInput, confirmBtn, selectedSeats) {
  hiddenInput.value = Array.from(selectedSeats).join(",");
  confirmBtn.disabled = selectedSeats.size === 0;
}
