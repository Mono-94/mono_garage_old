


document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".vehicle-info").forEach(function (expandirButton) {
    expandirButton.addEventListener("click", function () {
      var vehicleCard = this.closest(".vehicle-carta");
      var vehicleOptions = vehicleCard.querySelector(".vehicle-options");
      vehicleCard.classList.toggle("expanded");
      vehicleOptions.style.display = vehicleCard.classList.contains("expanded") ? "flex" : "none";
    });
  });
});

var lang = {};

$.getJSON("../ui/lang.json", function (data) {
  var idioma = data.SelectLang;
  lang = data.languages[idioma];
});

window.addEventListener("message", function (event) {
  switch (event.data.action) {
    case "garage":
      if (event.data.show === true) {
        $(".container").css("display", "block");
        $(".menu-titulo").text(event.data.garage.garage);
        $(".vehicle-list").empty();
        event.data.vehicles.forEach(function (vehicle) {
          var vehicleCard = $("<div>").addClass("vehicle-carta");
          var vehicleInfo = $("<div>").addClass("vehicle-info");
          if (event.data.garage.jobcar === undefined) {
            console.log('es nil')
            if (vehicle.stored === 0) {
              var vehicleParking = $("<div>").addClass("vehicle-parking").text(lang.fuera).css({
                "background-color": "#a52a2a99",
                "color": "#f59e9efb"
              });

            } else {
              var vehicleParking = $("<div>").addClass("vehicle-parking").text(lang.dentro).css({
                "background-color": "#2aa52a54",
                "color": "#bcffbc;"
              });
            }
          } else {
            console.log('vehiculos')
            var vehicleParking = $("<div>").addClass("vehicle-parking").text(vehicle.gradeName).css({
              "background-color": "#2aa52a54",
              "color": "#bcffbc;"
            });

          }
        
          var vehicleNameText = vehicle.name.charAt(0).toUpperCase() + vehicle.name.slice(1).toLowerCase();
          var vehicleMarcaText = vehicle.marca.charAt(0).toUpperCase() + vehicle.marca.slice(1).toLowerCase();

          var vehicleName = $("<div>").addClass("vehicle-name").text(vehicleNameText + "  " + vehicleMarcaText);
          var vehiclePlate = $("<div>").addClass("vehicle-plate").text(vehicle.plate);
         // var expandirButton = $("<button>").addClass("expandir").append($("<i>").addClass("fa-solid fa-caret-down"));

          var vehicleOptions = $("<div>").addClass("vehicle-options");
          var botonesContainer = $("<div>").addClass("botones");


          if (vehicle.stored === 0) {
            botonesContainer.append(
              $("<button>").addClass("deposito").text(lang.deposito)
            );
          } else {
            botonesContainer.append(
              $("<button>").addClass("retirar").text(lang.retirar)
            );
          }

          if (vehicle.isOwner === true) {
            botonesContainer.append(
              $("<button>").addClass("compartir").text(lang.compartir)
            );
          }
          var statusContainer = $("<div>").addClass("status");


          statusContainer.append(
            $("<div>").addClass("fuel-text").html(`<i class="fas fa-gas-pump"></i> ${lang.fuel}  ${vehicle.fuelLevel}%`),
            $("<div>").addClass("fuel").css("width", vehicle.fuelLevel + "%"),
            $("<div>").addClass("body-text").html(`<i class="fas fa-car"></i> ${lang.body} ${(vehicle.body / 10)}%`),
            $("<div>").addClass("body").css("width", (vehicle.body / 10) + "%"),
            $("<div>").addClass("engine-text").html(`<i class="fas fa-cogs"></i> ${lang.engine} ${(vehicle.engine / 10)}%`),
            $("<div>").addClass("engine").css("width", (vehicle.engine / 10) + "%")
          );

          vehicleInfo.on("click", function () {
           
            if (vehicleCard.hasClass("expanded")) {
              vehicleCard.removeClass("expanded");
            } else {
              vehicleCard.addClass( "expanded", 200);
            }
          });
          

          botonesContainer.find(".retirar").on("click", function () {
            CloseUi();
            $.post(`https://${GetParentResourceName()}/mono_garage`, JSON.stringify({ action: 'retirar', garage: event.data.garage, vehicle: vehicle, jobcar: event.data.garage.jobcar }));
          });
          botonesContainer.find(".deposito").on("click", function () {
            CloseUi();
            $.post(`https://${GetParentResourceName()}/mono_garage`, JSON.stringify({ action: 'depositar', garage: event.data.garage, vehicle: vehicle, jobcar: event.data.garage.jobcar }));
          });
          botonesContainer.find(".compartir").on("click", function () {
            $( function() {
              $( "#dialog" ).dialog();
            } );
          });
          vehicleInfo.append(vehicleParking, vehicleName, vehiclePlate); //expandirButton
          vehicleCard.append(vehicleInfo, vehicleOptions);
          vehicleOptions.append(botonesContainer, statusContainer);
          $(".vehicle-list").append(vehicleCard);
        });
      } else {
        $(".container").css("display", "none");
      }

      break;
  }
});





document.addEventListener("keydown", function (event) {
  if (event.keyCode === 27 || event.keyCode === 8) {
    CloseUi(); // 
  }
});

function CloseUi() {
  $.post(`https://${GetParentResourceName()}/exit`);
  $(".container").css("display", "none");
}





